unit Commands;

uses
  Game,
  Players,
  Skills,
  Cooldowns,
  Help,
  Globals;

procedure CmdAssign(var player: TActivePlayer; var args: Array of String);
var
  argTokens: Array of String;
  skill, points, i: Integer;
  unassigned: Integer;
begin
  unassigned := GetUnassignedSkillPoints(player);

  if unassigned <= 0 then
  begin
    player.WriteConsole('You don''t have any unassigned skill points!', RED);
    player.WriteConsole('Type /refund to reallocate skill points', RED);
  end

  else if Length(args) <= 1 then
  begin
    ShowPlayerSkills(player);
    HelpAssign(player);
  end

  else
  begin
    for i := 1 to Length(args) - 1 do
    begin
      argTokens := Split(args[i], ':');
      try
        skill := StrToInt(argTokens[0]);
        if Length(argTokens) > 1
          then points := StrToInt(argTokens[1])
          else points := 9999;
        AssignSkillPoints(player, skill, points);
      except
      end;
    end;

    if unassigned = GetUnassignedSkillPoints(player) then
    begin
      ShowPlayerSkills(player);
      HelpAssign(player);
    end
    else
      RefreshPlayerUI(player);
  end;
end;

procedure CmdRefund(var player: TActivePlayer; var args: Array of String);
var
  skill: Integer;
begin
  try
    skill := StrToInt(args[1]);
  except
    skill := 0;
  end;
  RefundSkillPoints(player, skill);
  RefreshPlayerUI(player);
end;

procedure CmdAuto(var player: TActivePlayer);
begin
  PlayersData[player.ID].manual := false;
  AutoDistributeSkillPoints(player);
  player.WriteConsole('Skill points will now be distributed automatically.', YELLOW);
  RefreshPlayerUI(player);
end;

procedure CmdPlayers(var player: TActivePlayer);
var
  i, j: Integer;
  ids: Array of Integer;
begin
  ids := GetActivePlayersSorted();

  player.WriteConsole('Current players:', ORANGE);
  for i := 0 to Length(ids) - 1 do
  begin
    player.WriteConsole(GetPlayerSummary(ids[i]), WHITE);
    for j := 1 to SKILLS_LENGTH do
      if PlayersData[ids[i]].skillRanks[j] > 0 then
        player.WriteConsole('  ' + GetPlayerSkill(Players[ids[i]], j), LIGHTGREY);
  end;
end;

procedure CmdRebirth(var player: TActivePlayer; var args: Array of String);
var
  arg: String;
begin
  try
    arg := UpperCase(args[1]);
  except
    arg := '';
  end;
  if arg = 'YES' then
  begin
    if (PlayersData[player.ID].level < 20) and
       (not PlayersData[player.ID].rebirth) then
      player.WriteConsole('You must be level 20 for rebirth!', RED)
    else
      PlayerRebirth(player);
  end
  else
    HelpRebirth(player);
end;

procedure CmdHelp(var player: TActivePlayer; var args: Array of String);
begin
  if Length(args) > 1
    then HelpCmd(player, args[1])
    else HelpGeneral(player);
end;

procedure CmdSkills(var player: TActivePlayer);
begin
  ShowPlayerSkills(player);
  HelpAssign(player);
end;

procedure CmdGust(var player: TActivePlayer; var args: Array of String);
begin
  try
    UseGust(player, args[1]);
  except
    HelpGust(player);
  end;
end;

procedure CmdKill(var player: TActivePlayer; var args: Array of String);
var
  id: Integer;
begin
  id := player.ID;
  if player.IsAdmin then
    try
      id := StrToInt(args[1]);
    except end;

  if Players[id].Alive then
  begin
    SetPlayerHP(Players[id], 0);
    Players[id].Damage(id, 100);
  end;
end;

procedure CmdSave(var player: TActivePlayer);
begin
  if player.IsAdmin then
  begin
    SaveAllPlayers();
    player.WriteConsole('All players saved!', YELLOW);
  end;
end;

procedure CmdResetCd(var player: TActivePlayer);
var
  i: Integer;
begin
  if player.IsAdmin then
  begin
    for i := 1 to 32 do
      ResetPlayerCooldowns(Players[i]);
    player.WriteConsole('All player cooldowns reset!', YELLOW);
  end;
end;

procedure CmdBot(var player: TActivePlayer; var args: Array of String);
var
  num, i: Integer;
begin
  if player.IsAdmin then
  begin
    try
      num := StrToInt(args[1]);
    except
      num := 1;
    end;
    for i := 1 to num do
      AddDumbBot();
  end;
end;

function HandleOnCommand(var player: TActivePlayer; cmd: String): Boolean;
var
  args: Array of String;
begin
  args := Split(cmd, ' ');

  result := true;

  case LowerCase(args[0]) of
    '/assign': CmdAssign(player, args);
    '/refund': CmdRefund(player, args);
    '/auto': CmdAuto(player);
    '/players': CmdPlayers(player);
    '/rebirth': CmdRebirth(player, args);
    // Unlisted commands
    '/help': CmdHelp(player, args);
    '/skills': CmdSkills(player);
    '/gust': CmdGust(player, args);
    '/kill': CmdKill(player, args);
    '/save': CmdSave(player);
    '/resetcd': CmdResetCd(player);
    '/bot': CmdBot(player, args);
  else
    result := false;
  end;
end;

procedure HandleOnSpeakCommand(var player: TActivePlayer; text: String);
var
  cmdText: String;
begin
  if (Pos('/', text) = 1) or (Pos('!', text) = 1) then
  begin
    cmdText := '/' + Copy(text, 2, Length(text));
    HandleOnCommand(player, cmdText);
  end;
end;

