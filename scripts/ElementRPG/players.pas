unit Players;

uses
  SaveFiles,
  SkillsInfo,
  Cooldowns,
  HUD,
  Math,
  Utils,
  Globals;

function KillExp(var killer, victim: TActivePlayer): Integer;
begin
  if killer.human then
  begin
    if victim.human then
      result := 100 + PlayersData[victim.ID].level * 8
    else
      result := 100
  end
  else
    result := 0;
end;

function ExpLevel(exp: Integer): Integer;
begin
  // Old quadratic formula
  (* result := Trunc(Sqrt(exp / 10) * 3 / 10) + 1; *)

  result := Trunc(Ln(exp/1300.0 + 1) * 8 + 1);
end;

function LevelExp(level: Integer): Integer;
var
  x: Double;
begin
  x := (level - 1) / 8.0;
  result := Trunc((Pow(E, x) - 1) * 1300) + 1;
end;

function LevelSkillPoints(level: Integer): Integer;
begin
  result := level - 1;
end;

function GetCurrentExp(player: TActivePlayer): Integer;
begin
  result := PlayersData[player.ID].exp + PlayersData[player.ID].expBoost;
end;

function GetExpToNextLevel(var player: TActivePlayer): Integer;
var
  nextExp: Integer;
begin
  nextExp := LevelExp(PlayersData[player.ID].level + 1);
  result := nextExp - GetCurrentExp(player);
end;

function GetExpPercentToNextLevel(var player: TActivePlayer): Integer;
var
  prevExp, nextExp: Integer;
begin
  prevExp := LevelExp(PlayersData[player.ID].level);
  nextExp := LevelExp(PlayersData[player.ID].level + 1);
  result := (GetCurrentExp(player) - prevExp) * 100 / (nextExp - prevExp);
end;

function GetUnassignedSkillPoints(var player: TActivePlayer): Integer;
begin
  result := LevelSkillPoints(PlayersData[player.ID].level) - PlayersData[player.ID].assignedSp;
  if result < 0 then
    result := 0;
end;

procedure NotifyUnassignedSkillPoints(var player: TActivePlayer);
var
  sp: Integer;
begin
  sp := GetUnassignedSkillPoints(player);
  if sp > 0 then
    player.WriteConsole(
      'You have ' + IntToStr(sp) + ' unassigned skill points.' +
      ' See ''/help'' for info.', YELLOW);
end;

function GetActivePlayersSorted(): Array of Integer;
var
  i, j, count, tmp: Integer;
  ids, exps: Array of Integer;
begin
  SetLength(ids, 32);
  SetLength(exps, 32);

  count := 0;
  for i := 1 to 32 do
    if Players[i].Active and Players[i].Human then
     begin
       ids[count] := Players[i].ID;
       exps[count] := GetCurrentExp(Players[i]);
       count := count + 1;
     end;

  SetLength(ids, count);
  SetLength(exps, count);

  for i := 0 to Length(ids) - 1 do
    for j := i + 1 to Length(ids) - 1 do
      if exps[j] > exps[i] then
      begin
        tmp := ids[i];
        ids[i] := ids[j];
        ids[j] := tmp;
        tmp := exps[i];
        exps[i] := exps[j];
        exps[j] := tmp;
      end;

  result := ids
end;

procedure RefreshPlayersList(excludePlayerId: Integer);
var
  activePlayerIds: Array of Integer;
  infoLength, infoIdx, i, j: Integer;
  playersInfo: Array of THudPlayerInfo;
begin
  activePlayerIds := GetActivePlayersSorted();

  infoLength := Length(activePlayerIds);
  for i := 0 to Length(activePlayerIds) - 1 do
    if activePlayerIds[i] = excludePlayerId then
      infoLength := infoLength - 1;

  SetLength(playersInfo, infoLength);

  infoIdx := 0;
  for i := 0 to Length(activePlayerIds) - 1 do
  begin
    if activePlayerIds[i] <> excludePlayerId then
    begin
      playersInfo[infoIdx].name := Players[activePlayerIds[i]].name;
      playersInfo[infoIdx].level := PlayersData[activePlayerIds[i]].level;
      playersInfo[infoIdx].manual := PlayersData[activePlayerIds[i]].manual;
      playersInfo[infoIdx].rebirth := PlayersData[activePlayerIds[i]].rebirth;
      for j := 1 to SKILLS_LENGTH do
        playersInfo[infoIdx].skillRanks[j] := PlayersData[activePlayerIds[i]].skillRanks[j];

      infoIdx := infoIdx + 1;
    end;
  end;

  for i := 1 to 32 do
    if Players[i].active then
      HudUpdatePlayers(Players[i], playersInfo);
end;

function GetMaxHP(var player: TActivePlayer): Single;
begin
  if player.human
    then result := 350 + (PlayersData[player.ID].level - 1) * 6
    else result := 200;
end;

procedure RefreshPlayerHP(player: TActivePlayer);
var
  i: Integer;
begin
  HudUpdateHP(player, PlayersData[player.ID].hp, GetMaxHP(player));

  for i := 1 to 32 do
  begin
    if LastAttackerIds[i] = player.ID then
      HudUpdateAttacker(
        Players[i], player.name, PlayersData[player.ID].level,
        PlayersData[player.ID].hp, GetMaxHP(player));

    if LastTargetIds[i] = player.ID then
      HudUpdateTarget(
        Players[i], player.name, PlayersData[player.ID].level,
        PlayersData[player.ID].hp, GetMaxHP(player));
  end;
end;

procedure RefreshPlayerSkills(player: TActivePlayer);
var
  skill: Integer;
begin
  for skill := 1 to SKILLS_LENGTH do
    HudUpdateSkill(player, skill, PlayersData[player.ID].skillRanks[skill], SkillMaxRanks[skill]);

  HudUpdateSkillPoints(player, GetUnassignedSkillPoints(player), PlayersData[player.ID].manual);
  RefreshPlayerCooldowns(player);
end;

procedure RefreshPlayerUI(var player: TActivePlayer);
begin
  HudUpdateLevel(
    player,
    PlayersData[player.ID].level,
    GetExpPercentToNextLevel(player),
    GetExpToNextLevel(player));
  RefreshPlayerHP(player);
  RefreshPlayerSkills(player);
  RefreshPlayersList(0);
end;

procedure SetPlayerHP(player: TActivePlayer; hp: Single);
var
  maxHP: Single;
begin
  maxHP := GetMaxHP(player);

  PlayersData[player.ID].hp := hp;

  if PlayersData[player.ID].hp < 0 then
    PlayersData[player.ID].hp := 0

  else if PlayersData[player.ID].hp > maxHP then
    PlayersData[player.ID].hp := maxHP;

  RefreshPlayerHP(player);
end;

function GetPlayerSummary(id: Integer): String;
begin
  result := Players[id].name;
  if PlayersData[id].rebirth then
    result := result + '*';
  result := result + ' - Level ' + IntToStr(PlayersData[id].level);
end;

function GetPlayerStats(var player: TActivePlayer): String;
begin
  result :=
    'Level ' + IntToStr(PlayersData[player.ID].level) +
    ' HP ' + IntToStr(Trunc(PlayersData[player.ID].hp)) + '/' + IntToStr(Trunc(GetMaxHP(player))) +
    ' [Exp: ' + IntToStr(GetExpPercentToNextLevel(player)) + '%' +
    ' next ' + IntToStr(GetExpToNextLevel(player)) + ']';
end;

function GetPlayerSkill(player: TActivePlayer; skill: Integer): String;
begin
  result :=
    SkillNames[skill] +
    ' [' + IntToStr(PlayersData[player.ID].skillRanks[skill]) +
    '/' + IntToStr(SkillMaxRanks[skill]) + '] - ' + SkillInfo[skill];
end;

procedure ShowPlayerSkills(var player: TActivePlayer);
var
  i: Integer;
  color: Longint;
begin
  player.WriteConsole('Available skills:', ORANGE);
  for i := 1 to SKILLS_LENGTH do
  begin
    if PlayersData[player.ID].skillRanks[i] >= SkillMaxRanks[i] then
      color := LIGHTYELLOW
    else if PlayersData[player.ID].skillRanks[i] > 0 then
      color := WHITE
    else
      color := LIGHTGREY;

    player.WriteConsole(IntToStr(i) + ': ' + GetPlayerSkill(player, i), color);
  end;
end;

procedure AssignSkillPoints(var player: TActivePlayer; skill, points: Integer);
var
  adjustedPoints, curRank: Integer;
  rankMsg: String;
begin
  if not ((skill > 0) and (skill <= SKILLS_LENGTH)) then
    player.WriteConsole(IntToStr(skill) + ' is not a valid skill number', RED)

  else
  begin
    adjustedPoints := points;

    if adjustedPoints > GetUnassignedSkillPoints(player) then
      adjustedPoints := GetUnassignedSkillPoints(player);

    curRank := PlayersData[player.ID].skillRanks[skill];

    if adjustedPoints > 0 then
    begin
      if curRank >= SkillMaxRanks[skill] then
        player.WriteConsole(SkillNames[skill] + ' is already at max rank', RED)
      else
      begin
        if curRank + adjustedPoints > SkillMaxRanks[skill] then
          adjustedPoints := SkillMaxRanks[skill] - curRank;

        if adjustedPoints > 0 then
        begin
          PlayersData[player.ID].skillRanks[skill] := curRank + adjustedPoints;
          PlayersData[player.ID].assignedSp := PlayersData[player.ID].assignedSp + adjustedPoints;

          if PlayersData[player.ID].skillRanks[skill] = SkillMaxRanks[skill]
            then rankMsg := 'MAXED'
            else rankMsg := 'rank ' + IntToStr(PlayersData[player.ID].skillRanks[skill]);

          player.WriteConsole(
            'You assigned ' + IntToStr(adjustedPoints) + ' skill points to ' +
            SkillNames[skill] + ' (now ' + rankMsg + ')',
            GREEN);
        end;
      end;
    end;
  end;
end;

procedure RefundSkillPoints(var player: TActivePlayer; skill: Integer);
var
  skillRank: Integer;
  i: Integer;
begin
  if (skill < 0) or (skill > SKILLS_LENGTH) then
    player.WriteConsole('Invalid skill specified', RED)

  else if skill = 0 then
  begin
    if LevelSkillPoints(PlayersData[player.ID].level) <= 0 then
      player.WriteConsole('You haven''t unlocked any skills yet!', RED)

    else
    begin
      for i := 1 to SKILLS_LENGTH do
        PlayersData[player.ID].skillRanks[i] := 0;
      PlayersData[player.ID].assignedSp := 0;
      player.WriteConsole('All your skills points have been refunded.', CYAN);
    end;
  end

  else
  begin
    skillRank := PlayersData[player.ID].skillRanks[skill];

    if skillRank < 0 then
      RefundSkillPoints(player, 0)

    else if skillRank = 0 then
      player.WriteConsole(
        'You haven''t assigned any points to ' + SkillNames[skill] + ' yet', RED)

    else
    begin
      PlayersData[player.ID].skillRanks[skill] := 0;
      PlayersData[player.ID].assignedSp := PlayersData[player.ID].assignedSp - skillRank;
      player.WriteConsole('Skill points for ' + SkillNames[skill] + ' have been refunded.', CYAN);
    end;
  end;

  if (not PlayersData[player.ID].manual) and (GetUnassignedSkillPoints(player) > 0) then
  begin
    PlayersData[player.ID].manual := true;
    player.WriteConsole('Skill points will no longer be distributed automatically.', YELLOW);
    player.WriteConsole('Use the /assign command to allocate skill points manually.', YELLOW);
  end;
end;

procedure AutoDistributeSkillPoints(var player: TActivePlayer);
var
  choices: Array[0..SKILLS_LENGTH-1] of Integer;
  choicesCount: Integer;
  skill, i: Integer;
begin
  if not PlayersData[player.ID].manual then
  begin
    while GetUnassignedSkillPoints(player) > 0 do
    begin
      choicesCount := 0;
      for i := 1 to SKILLS_LENGTH do
      begin
        if (PlayersData[player.ID].skillRanks[i] < SkillMaxRanks[i]) and SkillPassive[i] then
        begin
          choices[choicesCount] := i;
          choicesCount := choicesCount + 1;
        end;
      end;

      if choicesCount = 0 then
        break;

      skill := 0;

      for i := 0 to choicesCount - 1 do
      begin
        if PlayersData[player.ID].skillRanks[choices[i]] > 0 then
        begin
          skill := choices[i];
          break;
        end;
      end;

      if skill = 0 then
        skill := choices[Random(0, choicesCount)];

      AssignSkillPoints(player, skill, 9999);
    end;
  end;
end;

procedure GrantExp(var player: TActivePlayer; exp: Integer);
var
  prevLevel: Integer;
begin
  prevLevel := PlayersData[player.ID].level;

  PlayersData[player.ID].exp := PlayersData[player.ID].exp + exp;
  PlayersData[player.ID].level := ExpLevel(GetCurrentExp(player));

  HudUpdateLevel(
    player,
    PlayersData[player.ID].level,
    GetExpPercentToNextLevel(player),
    GetExpToNextLevel(player));

  if PlayersData[player.ID].level > prevLevel then
  begin
    player.WriteConsole('You are now level ' + IntToStr(PlayersData[player.ID].level) + '!', YELLOW);
    HudShowLevelUp(player);
    AutoDistributeSkillPoints(player);
    RefreshPlayerUI(player);
  end;
end;

procedure BoostPlayer(player: TActivePlayer; targetLevel: Integer);
var
  targetLevelCapped: Integer;
begin
  targetLevelCapped := Trunc(Min(targetLevel, 100));

  if player.Active and player.Human and
     (PlayersData[player.ID].level < targetLevelCapped) then
  begin
    PlayersData[player.ID].expBoost := LevelExp(targetLevelCapped) - PlayersData[player.ID].exp;
    GrantExp(player, 0);
    player.WriteConsole(
      'You have been temporarily boosted to level ' + IntToStr(PlayersData[player.ID].level) +
      ' by an admin!', YELLOW);
  end;
end;

procedure GivePlayerSpawnAmmo(player: TActivePlayer);
begin
  if not PlayersData[player.ID].spawnAmmoGiven then
  begin
    PlayersData[player.ID].spawnAmmoGiven := true;
    if player.primary.WType = WTYPE_M79 then
      player.primary.ammo := GetWeaponMaxAmmo(WTYPE_M79);
  end;
end;

procedure PlayerRebirth(var player: TActivePlayer);
var
  i: Integer;
begin
  SetPlayerHP(player, 0);
  player.Damage(player.ID, 100);

  PlayersData[player.ID].expBanked :=
    PlayersData[player.ID].expBanked + PlayersData[player.ID].exp;
  PlayersData[player.ID].exp := 0;
  PlayersData[player.ID].expBoost := 0;
  PlayersData[player.ID].level := 1;
  PlayersData[player.ID].manual := false;
  PlayersData[player.ID].rebirth := true;
  for i := 1 to SKILLS_LENGTH do
    PlayersData[player.ID].skillRanks[i] := 0;
  PlayersData[player.ID].assignedSp := 0;

  player.WriteConsole('You are reborn!', YELLOW);
  player.WriteConsole('Welcome to Level 1, Noob!', YELLOW);

  RefreshPlayerUI(player);
end;

procedure SavePlayer(player: TActivePlayer);
var
  saveData: TSaveData;
  i: Integer;
begin
  if player.human then
  begin
    saveData.name := player.Name;
    saveData.hwid := player.HWID;
    saveData.exp := PlayersData[player.ID].exp + PlayersData[player.ID].expBanked;
    saveData.level := ExpLevel(saveData.exp);
    saveData.manual := PlayersData[player.ID].manual;

    for i := 1 to SKILLS_LENGTH do
      saveData.skillRanks[i] := PlayersData[player.ID].skillRanks[i];

    WriteSaveFile(saveData);
  end;
end;

procedure SaveAllPlayers();
var
  i: Integer;
begin
  for i := 1 to 32 do
    if Players[i].Active and Players[i].Human then
      SavePlayer(Players[i]);
end;

procedure LoadPlayer(var player: TActivePlayer);
var
  saveData: TSaveData;
  skillRank, skillRanksTotal: Integer;
  i: Integer;
begin
  saveData := ReadSaveFile(player.HWID);

  PlayersData[player.ID].player := player;
  PlayersData[player.ID].exp := saveData.exp;
  PlayersData[player.ID].level := ExpLevel(PlayersData[player.ID].exp);
  PlayersData[player.ID].expBanked := 0;
  PlayersData[player.ID].expBoost := 0;
  PlayersData[player.ID].manual := saveData.manual;
  PlayersData[player.ID].rebirth := false;

  skillRanksTotal := 0;
  for i := 1 to SKILLS_LENGTH do
  begin
    skillRank := saveData.skillRanks[i];
    if skillRank > SkillMaxRanks[i] then
      skillRank := SkillMaxRanks[i];

    if skillRanksTotal + skillRank > LevelSkillPoints(PlayersData[player.ID].level) then
      skillRank := LevelSkillPoints(PlayersData[player.ID].level) - skillRanksTotal;

    PlayersData[player.ID].skillRanks[i] := skillRank;
    skillRanksTotal := skillRanksTotal + skillRank;
  end;

  PlayersData[player.ID].assignedSp := skillRanksTotal;
end;

procedure ClearPlayerFromAttackerTarget(var player: TActivePlayer);
var
  i: Integer;
begin
  HudUpdateAttacker(player, '', 0, 0, 0);
  HudUpdateTarget(player, '', 0, 0, 0);

  LastAttackerIds[player.ID] := 0;
  LastTargetIds[player.ID] := 0;

  for i := 1 to 32 do
  begin
    if LastAttackerIds[i] = player.ID then
    begin
      HudUpdateAttacker(Players[i], '', 0, 0, 0);
      LastAttackerIds[i] := 0;
    end;
    if LastTargetIds[i] = player.ID then
    begin
      HudUpdateTarget(Players[i], '', 0, 0, 0);
      LastTargetIds[i] := 0;
    end;
  end;
end;

procedure InitPlayerSpawn(var player: TActivePlayer);
begin
  ClearPlayerFromAttackerTarget(player);

  SetPlayerHP(player, GetMaxHP(player));
  PlayersData[player.ID].spawnAmmoGiven := false;
  PlayersData[player.ID].spawnTick := LastTick;

  player.WeaponActive[Weap2Menu(WTYPE_KNIFE)] := false;

  HudShowSkillsHeading(player);
  RefreshPlayerUI(player);
end;

procedure InitPlayer(var player: TActivePlayer);
begin
  LoadPlayer(player);

  player.WriteConsole('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', ORANGE);
  player.WriteConsole('Welcome, this server is running ElementRPG mod!', ORANGE);
  player.WriteConsole('Type /help to get started', ORANGE);
  player.WriteConsole('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', ORANGE);

  if PlayersData[player.ID].level > 1 then
  begin
    player.WriteConsole(GetPlayerStats(player), CYAN);
    AutoDistributeSkillPoints(player);
    NotifyUnassignedSkillPoints(player);
  end;

  InitPlayerSpawn(player);
end;
