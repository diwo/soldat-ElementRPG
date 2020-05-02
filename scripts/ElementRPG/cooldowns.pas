unit Cooldowns;

uses
  SkillsInfo,
  Utils,
  Globals;

var
  SkillLastUsedTick: Array[1..32] of Array[1..SKILLS_LENGTH] of Integer;
  SkillCooldownReduction: Array[1..32] of Array[1..SKILLS_LENGTH] of Integer;

function CooldownTicks(var player: TActivePlayer; skill: Integer): Integer;
begin
  result := Trunc(RankInterpolate(
    SkillCooldownLow[skill], SkillCooldownHigh[skill],
    skill, PlayersData[player.ID].skillRanks[skill]));
end;

function CooldownTicksRemaining(var player: TActivePlayer; skill: Integer): Integer;
var
  elapsed, cd, reduction: Integer;
begin
  elapsed := LastTick - SkillLastUsedTick[player.ID][skill];
  cd := CooldownTicks(player, skill);
  reduction := SkillCooldownReduction[player.ID][skill];
  cd := cd - reduction;
  if (SkillLastUsedTick[player.ID][skill] > 0) and (elapsed < cd)
    then result := cd - elapsed
    else result := 0;
end;

function TicksSinceSkillUsed(var player: TActivePlayer; skill: Integer): Integer;
begin
  if SkillLastUsedTick[player.ID][skill] > 0
    then result := LastTick - SkillLastUsedTick[player.ID][skill]
    else result := -1;
end;

procedure RefreshPlayerCooldowns(player: TActivePlayer);
var
  cooldownsInfo: Array of THudCooldownInfo;
  infoLength, infoIdx, i: Integer;
begin
  if player.active then
  begin
    infoLength := 0;
    for i := 1 to SKILLS_LENGTH do
      if SkillShowCooldown[i] and (PlayersData[player.ID].skillRanks[i] > 0) then
        infoLength := infoLength + 1;

    SetLength(cooldownsInfo, infoLength);

    infoIdx := 0;
    for i := 1 to SKILLS_LENGTH do
    begin
      if SkillShowCooldown[i] and (PlayersData[player.ID].skillRanks[i] > 0) then
      begin
        cooldownsInfo[infoIdx].name := SkillNames[i];
        cooldownsInfo[infoIdx].cooldownSeconds :=
          CooldownTicksRemaining(player, i) / 60;
        infoIdx := infoIdx + 1;
      end;
    end;

    HudUpdateCooldowns(player, cooldownsInfo);
  end;
end;

procedure SetSkillLastUsedTick(var player: TActivePlayer; skill: Integer);
begin
  SkillLastUsedTick[player.ID][skill] := LastTick;
  SkillCooldownReduction[player.ID][skill] := 0;
  RefreshPlayerCooldowns(player);
end;

procedure ReduceSkillCooldown(var player: TActivePlayer; skill, reduction: Integer);
begin
  SkillCooldownReduction[player.ID][skill] := SkillCooldownReduction[player.ID][skill] + reduction;
end;

procedure ResetCooldown(player: TActivePlayer; skill: Integer);
begin
  SkillLastUsedTick[player.ID][skill] := 0;
  SkillCooldownReduction[player.ID][skill] := 0;
  RefreshPlayerCooldowns(player);
end;

procedure ResetPlayerCooldowns(player: TActivePlayer);
var
  i: Integer;
begin
  for i := 1 to SKILLS_LENGTH do
    ResetCooldown(player, i);
end;

procedure InitCooldowns();
var
  i, j: Integer;
begin
  for i := 1 to 32 do
    for j := 1 to SKILLS_LENGTH do
    begin
      SkillLastUsedTick[i][j] := 0;
      SkillCooldownReduction[i][j] := 0;
    end;
end;

begin
  InitCooldowns;
end.
