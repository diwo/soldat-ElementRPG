unit DamageIndicator;

uses
  Math,
  Globals;

const DAMAGE_INDICATOR_LAYERS_MAX = 8;

const
  LAYER_DAMAGE_DEALT = LAYER_DAMAGE_INDICATOR;
  LAYER_DAMAGE_TAKEN = LAYER_DAMAGE_INDICATOR + DAMAGE_INDICATOR_LAYERS_MAX;
  LAYER_DAMAGE_HEALED = LAYER_DAMAGE_INDICATOR + DAMAGE_INDICATOR_LAYERS_MAX * 2;
  LAYER_EXP_GAINED = LAYER_DAMAGE_INDICATOR + DAMAGE_INDICATOR_LAYERS_MAX * 3;

var
  DamageDealtLayerOffset: Array[1..32] of Integer;
  DamageTakenLayerOffset: Array[1..32] of Integer;
  ExpGainedLayerOffset: Array[1..32] of Integer;

function DamageIndicatorDuration(damage: Single): Integer;
begin
  result := Trunc(InterpolateQuadratic(80, 150, 0, 500, damage));
end;

function DamageIndicatorColor(damage: Single): Longint;
begin
  if damage < 10 then result := GREY
  else if damage < 150 then result := YELLOW
  else if damage < 500 then result := RED
  else result := ORANGE;
end;

function DamageIndicatorSize(damage: Single): Single;
begin
  result := InterpolateLinear(0.03, 0.05, 0, 500, damage);
end;

function DamageIndicatorXOffset(damage: Single): Single;
begin
  if damage < 10 then result := 2
  else if damage < 100 then result := 5
  else if damage < 350 then result := 8
  else if damage < 1000 then result := 10
  else result := 15;
end;

procedure DamageDealtIndicator(var player, victim: TActivePlayer; damage: Single);
var
  xoffset, yoffset: Single;
begin
  DamageDealtLayerOffset[player.ID] :=
    (DamageDealtLayerOffset[player.ID] + 1) mod DAMAGE_INDICATOR_LAYERS_MAX;

  xoffset := RandomFixed(-100, 100) / 100.0 * 10.0;
  yoffset := RandomFixed(-100, 100) / 100.0 * 5.0;

  xoffset := xoffset * (1 - Min(damage, 500)/800);
  yoffset := yoffset * (1 - Min(damage, 500)/800);

  player.WorldText(
    LAYER_DAMAGE_DEALT + DamageDealtLayerOffset[player.ID],
    IntToStr(Trunc(damage)),
    DamageIndicatorDuration(damage),
    DamageIndicatorColor(damage),
    DamageIndicatorSize(damage),
    victim.x - DamageIndicatorXOffset(damage) + xoffset,
    victim.y - 30 + yoffset);
end;

procedure DamageTakenIndicator(var player: TActivePlayer; damage: Single);
var
  xoffset, yoffset: Single;
begin
  DamageTakenLayerOffset[player.ID] :=
    (DamageTakenLayerOffset[player.ID] + 1) mod DAMAGE_INDICATOR_LAYERS_MAX;

  xoffset := RandomFixed(-100, 100) * 10.0 / 100.0;
  yoffset := RandomFixed(-100, 100) * 5.0 / 100.0;

  xoffset := xoffset * (1 - Min(damage, 500)/800);
  yoffset := yoffset * (1 - Min(damage, 500)/800);

  player.WorldText(
    LAYER_DAMAGE_TAKEN + DamageTakenLayerOffset[player.ID],
    IntToStr(Trunc(damage)), 60*3/2,
    DamageIndicatorColor(damage),
    DamageIndicatorSize(damage),
    player.x - DamageIndicatorXOffset(damage) + xoffset,
    player.y - 30 + yoffset);
end;

procedure DamageHealedIndicator(var player: TActivePlayer; damage: Single);
begin
  player.WorldText(
    LAYER_DAMAGE_HEALED,
    IntToStr(Trunc(damage)), 60*1, GREEN,
    DamageIndicatorSize(damage),
    player.x - DamageIndicatorXOffset(damage),
    player.y - 30);
end;

function ExpGainedIndicatorSize(exp: Integer): Single;
begin
  result := InterpolateLinear(0.03, 0.06, 0, 500, exp);
end;

function ExpGainedIndicatorXOffset(exp: Integer): Single;
begin
  result := InterpolateLinear(15, 25, 0, 500, exp);
end;

procedure ExpGainedIndicator(var player, victim: TActivePlayer; exp: Integer);
begin
  ExpGainedLayerOffset[player.ID] :=
    (ExpGainedLayerOffset[player.ID] + 1) mod DAMAGE_INDICATOR_LAYERS_MAX;

  player.WorldText(
    LAYER_EXP_GAINED + ExpGainedLayerOffset[player.ID],
    IntToStr(exp) + ' exp', 60*2, CYAN,
    ExpGainedIndicatorSize(exp),
    victim.x - ExpGainedIndicatorXOffset(exp),
    victim.y - 45);
end;

procedure InitDamageIndicator();
var
  i: Integer;
begin
  for i := 1 to 32 do
  begin
    DamageDealtLayerOffset[i] := 0;
    DamageTakenLayerOffset[i] := 0;
    ExpGainedLayerOffset[i] := 0;
  end;
end;

begin
  InitDamageIndicator();
end.
