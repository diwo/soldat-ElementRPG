unit HUD;

uses
  SkillsInfo,
  Globals;

const
  HUD_TEXT_DURATION_PERM = 5184000;
  HUD_SKILLS_X_OFFSET = 20;
  HUD_SKILLS_Y_OFFSET = 80;
  HUD_PLAYERS_X_OFFSET = 720;
  HUD_PLAYERS_Y_OFFSET = 180;
  HUD_ATTACKER_X_OFFSET = 190;
  HUD_ATTACKER_Y_OFFSET = 350;
  HUD_TARGET_X_OFFSET = 520;
  HUD_TARGET_Y_OFFSET = 350;

type
  THudCooldownInfo = record
    name: String;
    cooldownSeconds: Integer;
  end;

  THudPlayerInfo = record
    id: Integer;
    name: String;
    level: Integer;
    manual: Boolean;
    rebirth: Boolean;
    skillRanks: Array[1..SKILLS_LENGTH] of Integer;
  end;

var
  HudPlayersLayerMax: Integer;

function HudGetHPString(hp, max: Single): String;
begin
  result := IntToStr(Trunc(hp)) + ' / ' + IntToStr(Trunc(max));
end;

function HudGetHPColor(hp, max: Single): Longint;
var
  percent: Single;
begin
  percent := hp / max * 100;

  if percent > 80 then
    result := GREEN
  else if percent > 50 then
    result := YELLOW
  else if percent > 25 then
    result := ORANGE
  else
    result := RED;
end;

procedure HudUpdateHP(player: TActivePlayer; hp, max: Single);
begin
  player.BigText(
    LAYER_HP, HudGetHPString(hp, max), HUD_TEXT_DURATION_PERM,
    HudGetHPColor(hp, max), 0.07, 55, 440);
end;

procedure HudUpdateLevel(player: TActivePlayer; level, expPercent, expNext: Integer);
begin
  player.BigText(
    LAYER_LEVEL, 'Level ' + IntToStr(level), HUD_TEXT_DURATION_PERM,
    ORANGE, 0.09, 355, 420);

  player.BigText(
    LAYER_EXP, 'exp ' + IntToStr(expPercent) + '% next ' + IntToStr(expNext),
    HUD_TEXT_DURATION_PERM, LIGHTGREY, 0.04, 352, 410);
end;

procedure HudShowLevelUp(player: TActivePlayer);
begin
  player.BigText(LAYER_LEVELUP, 'Level Up!', 60*3, ORANGE, 0.2, 295, 350);
end;

procedure HudUpdateAttacker(
  player: TActivePlayer; attackerName: String;
  attackerLevel: Integer; attackerHP, attackerMaxHP: Single);
begin
  if attackerName <> '' then
  begin
    player.BigText(
      LAYER_ATTACKER_LABEL, 'Attacker', HUD_TEXT_DURATION_PERM,
      WHITE, 0.06, HUD_ATTACKER_X_OFFSET, HUD_ATTACKER_Y_OFFSET);

    player.BigText(
      LAYER_ATTACKER_NAME,
      Copy(attackerName, 1, 15) + ' (Lv ' + IntToStr(attackerLevel) + ')',
      HUD_TEXT_DURATION_PERM, LIGHTGREY, 0.05,
      HUD_ATTACKER_X_OFFSET, HUD_ATTACKER_Y_OFFSET + 10);

    player.BigText(
      LAYER_ATTACKER_HP, HudGetHPString(attackerHP, attackerMaxHP), HUD_TEXT_DURATION_PERM,
      HudGetHPColor(attackerHP, attackerMaxHP), 0.05,
      HUD_ATTACKER_X_OFFSET, HUD_ATTACKER_Y_OFFSET + 20);
  end
  else
  begin
    player.BigText(LAYER_ATTACKER_LABEL, '', 0, 0, 0, 0, 0);
    player.BigText(LAYER_ATTACKER_NAME, '', 0, 0, 0, 0, 0);
    player.BigText(LAYER_ATTACKER_HP, '', 0, 0, 0, 0, 0);
  end;
end;

procedure HudUpdateTarget(
  player: TActivePlayer; targetName: String;
  targetLevel: Integer; targetHP, targetMaxHP: Single);
begin
  if targetName <> '' then
  begin
    player.BigText(
      LAYER_TARGET_LABEL, 'Target', HUD_TEXT_DURATION_PERM,
      WHITE, 0.06, HUD_TARGET_X_OFFSET, HUD_TARGET_Y_OFFSET);

    player.BigText(
      LAYER_TARGET_NAME,
      Copy(targetName, 1, 15) + ' (Lv ' + IntToStr(targetLevel) + ')',
      HUD_TEXT_DURATION_PERM, LIGHTGREY, 0.05,
      HUD_TARGET_X_OFFSET, HUD_TARGET_Y_OFFSET + 10);

    player.BigText(
      LAYER_TARGET_HP, HudGetHPString(targetHP, targetMaxHP), HUD_TEXT_DURATION_PERM,
      HudGetHPColor(targetHP, targetMaxHP), 0.05,
      HUD_TARGET_X_OFFSET, HUD_TARGET_Y_OFFSET + 20);
  end
  else
  begin
    player.BigText(LAYER_TARGET_LABEL, '', 0, 0, 0, 0, 0);
    player.BigText(LAYER_TARGET_NAME, '', 0, 0, 0, 0, 0);
    player.BigText(LAYER_TARGET_HP, '', 0, 0, 0, 0, 0);
  end;
end;

procedure HudShowSkillsHeading(player: TActivePlayer);
begin
  player.BigText(
    LAYER_SKILLS, 'Available skills', HUD_TEXT_DURATION_PERM,
    ORANGE, 0.04, HUD_SKILLS_X_OFFSET, HUD_SKILLS_Y_OFFSET);
end;

procedure HudUpdateSkill(player: TActivePlayer; skill, rank, max: Integer);
var
  text: String;
  color: Longint;
  layer: Integer;
begin
  text := IntToStr(skill) + ': ' + SkillNames[skill] +
          ' [' + IntToStr(rank) + '/' + IntToStr(max) + ']';

  if rank >= SkillMaxRanks[skill] then
    color := WHITE
  else if rank > 0 then
    color := LIGHTGREY
  else
    color := GREY;

  layer := LAYER_SKILLS + skill;

  player.BigText(
    layer, text, HUD_TEXT_DURATION_PERM,
    color, 0.03, HUD_SKILLS_X_OFFSET, HUD_SKILLS_Y_OFFSET + 2 + skill * 10);
end;

procedure HudUpdateSkillPoints(player: TActivePlayer; points: Integer; manual: Boolean);
var
  text: String;
begin
  if points > 0 then
  begin
    text := IntToStr(points) + ' skill points remaining';
    player.BigText(
      LAYER_SP_INFO_1, text, HUD_TEXT_DURATION_PERM,
      YELLOW, 0.03, HUD_SKILLS_X_OFFSET, HUD_SKILLS_Y_OFFSET + SKILLS_LENGTH * 10 + 20);

    text := 'Type /assign to allocate points';
    player.BigText(
      LAYER_SP_INFO_2, text, HUD_TEXT_DURATION_PERM,
      YELLOW, 0.03, HUD_SKILLS_X_OFFSET, HUD_SKILLS_Y_OFFSET + SKILLS_LENGTH * 10 + 28);
  end
  else if not manual then
  begin
    player.BigText(
      LAYER_SP_INFO_1, 'Auto-assign mode ON', HUD_TEXT_DURATION_PERM,
      YELLOW, 0.03, HUD_SKILLS_X_OFFSET, HUD_SKILLS_Y_OFFSET + SKILLS_LENGTH * 10 + 20);

    player.BigText(
      LAYER_SP_INFO_2, 'Type /help to assign manually', HUD_TEXT_DURATION_PERM,
      YELLOW, 0.03, HUD_SKILLS_X_OFFSET, HUD_SKILLS_Y_OFFSET + SKILLS_LENGTH * 10 + 28);
  end
  else
  begin
    player.BigText(LAYER_SP_INFO_1, '', 0, 0, 0, 0, 0);
    player.BigText(LAYER_SP_INFO_2, '', 0, 0, 0, 0, 0);
  end;
end;

procedure HudUpdateCooldowns(player: TActivePlayer; cooldownsInfo: Array of THudCooldownInfo);
var
  y, i: Integer;
  text: String;
  color: Longint;
begin
  // start below bottom of skills list
  y := HUD_SKILLS_Y_OFFSET + SKILLS_LENGTH * 10 + 50;

  if Length(cooldownsInfo) > 0 then
    player.BigText(
      LAYER_COOLDOWNS, 'Cooldowns', HUD_TEXT_DURATION_PERM,
      ORANGE, 0.04, HUD_SKILLS_X_OFFSET, y)
  else
    player.BigText(LAYER_COOLDOWNS, '', 0, 0, 0, 0, 0);

  y := y + 12;

  for i := 0 to Length(cooldownsInfo) - 1 do
  begin
    text := cooldownsInfo[i].name + ' - ';
    if cooldownsInfo[i].cooldownSeconds <= 0 then
    begin
      text := text + 'Ready';
      color := WHITE;
    end
    else begin
      text := text + IntToStr(cooldownsInfo[i].cooldownSeconds) + 's';
      color := LIGHTGREY;
    end;

    player.BigText(
      LAYER_COOLDOWNS + 1 + i, text, HUD_TEXT_DURATION_PERM,
      color, 0.03, HUD_SKILLS_X_OFFSET, y);

    y := y + 10;
  end;

  for i := 1 to SKILLS_LENGTH - Length(cooldownsInfo) do
    player.BigText(LAYER_COOLDOWNS + Length(cooldownsInfo) + i, '', 0, 0, 0, 0, 0);
end;

procedure HudUpdatePlayers(player: TActivePlayer; playersInfo: Array of THudPlayerInfo);
var
  layer, y, rank, i, j: Integer;
  text: String;
  color: Longint;
begin
  layer := LAYER_PLAYERS;
  y := HUD_PLAYERS_Y_OFFSET;

  player.BigText(
    layer, 'Players', HUD_TEXT_DURATION_PERM,
    ORANGE, 0.04, HUD_PLAYERS_X_OFFSET, y);

  y := y + 10;

  for i := 0 to Length(playersInfo) - 1 do
  begin
    layer := layer + 1;

    text := '';
    if player.IsAdmin then
      text := text + IntToStr(playersInfo[i].id) + ': ';

    text := text + Copy(playersInfo[i].name, 1, 15);
    if playersInfo[i].rebirth then
      text := text + '*';
    text := text + ' (Lv ' + IntToStr(playersInfo[i].level) + ')';

    if playersInfo[i].manual
      then color := YELLOW
      else color := WHITE;

    player.BigText(layer, text, HUD_TEXT_DURATION_PERM, color, 0.04, HUD_PLAYERS_X_OFFSET, y);

    y := y + 10;

    for j := 1 to SKILLS_LENGTH do
    begin
      rank := playersInfo[i].skillRanks[j];
      if rank > 0 then
      begin
        if rank >= SkillMaxRanks[j]
          then color := WHITE
          else color := LIGHTGREY;

        layer := layer + 1;

        player.BigText(
          layer,
          SkillNames[j] + ' [' + IntToStr(rank) + '/' + IntToStr(SkillMaxRanks[j]) + ']',
          HUD_TEXT_DURATION_PERM, color, 0.03, HUD_PLAYERS_X_OFFSET + 5, y);

        y := y + 8;
      end;
    end;

    y := y + 2;
  end;

  if layer > HudPlayersLayerMax then
    HudPlayersLayerMax := layer;

  for i := layer + 1 to HudPlayersLayerMax do
    player.BigText(i, '', 0, 0, 0, 0, 0);
end;
