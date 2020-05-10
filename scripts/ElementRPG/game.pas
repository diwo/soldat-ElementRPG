unit Game;

uses
  Players,
  Skills,
  Weapons,
  DamageIndicator,
  Utils,
  Globals;

var
  lastSaveTick: Integer;
  lastPerSecondTick: Integer;
  timestopActive: Boolean;
  timestopEndTick: Integer;

function HandleOnBeforeRespawn(player: TActivePlayer): Byte;
begin
  InitPlayerSpawn(player);

  FillScreen(player, LAYER_SMOKESCREEN_SELF, 0, $FF000000);
  FillScreen(player, LAYER_SMOKESCREEN_OTHER, 0, $FF000000);
  FillScreen(player, LAYER_FLASH, 0, $FF000000);
  FillScreen(player, LAYER_CRYSTALLINE_SHIELD, 0, $FF000000);

  result := 0;
end;

function HandleOnDamage(var shooter, victim: TActivePlayer; damage: Single; bulletId: Byte): Single;
var
  dmgAdjusted, dist: Single;
  weaponType, bulletStyle: Integer;
begin
  dmgAdjusted := damage;

  if (bulletId > 0) and (bulletId < 255) then
  begin
    weaponType := Map.Bullets[bulletId].GetOwnerWeaponId();
    bulletStyle := Map.Bullets[bulletId].Style;
    dist := DistancePlayers(shooter, victim);

    dmgAdjusted := WeaponDamageAdjust(
      shooter, victim, dist,
      weaponType, bulletStyle,
      dmgAdjusted);

    // Negative value indicates error such as bullet desync
    if dmgAdjusted < 0 then
    begin
      result := 0;
      exit;
    end;

    if bulletStyle <> BULLET_FLAME then
      UseFlameBarrier(victim, shooter, dmgAdjusted);
  end;

  UseStormCharge(shooter, victim);
  UseMagicMissile(shooter, victim);
  UseMagneticGrasp(shooter, victim);
  UseBlindingFlash(shooter, victim);
  UseShock(shooter, victim);

  if not shooter.human then
    dmgAdjusted := dmgAdjusted * 0.5;

  dmgAdjusted := ApplyTimestopDamage(shooter, dmgAdjusted);
  dmgAdjusted := ApplyBarkskin(victim, dmgAdjusted);
  // 255 = environmental damage
  if (victim = shooter) and (bulletId <> 255) then
    dmgAdjusted := ApplyEarthenEmbrace(victim, dmgAdjusted);
  dmgAdjusted := ApplyCrystallineShield(victim, shooter, dmgAdjusted);
  dmgAdjusted := ApplySmokeScreen(victim, shooter, dmgAdjusted);

  (* if (bulletId > 0) and (bulletId < 255) then *)
  (*   Debug( *)
  (*     WeapIdToStr(Map.Bullets[bulletId].GetOwnerWeaponId()) + *)
  (*     '/' + BulletStyleToStr(Map.Bullets[bulletId].Style) + *)
  (*     ' dmg=' + FloatToStrTrunc(damage, 1) + *)
  (*     ' adjusted=' + FloatToStrTrunc(dmgAdjusted, 1) + *)
  (*     ' dist=' + FloatToStrTrunc(DistancePlayers(shooter, victim), 1)); *)

  DamageTakenIndicator(victim, dmgAdjusted);
  if shooter <> victim then
    DamageDealtIndicator(shooter, victim, dmgAdjusted);

  SetPlayerHP(victim, PlayersData[victim.ID].hp - dmgAdjusted);
  if PlayersData[victim.ID].hp < 0 then
    SetPlayerHP(victim, 0);

  if victim <> shooter then
  begin
    HudUpdateAttacker(
      victim, shooter.name, PlayersData[shooter.ID].level,
      PlayersData[shooter.ID].hp, GetMaxHP(shooter));
    HudUpdateTarget(
      shooter, victim.name, PlayersData[victim.ID].level,
      PlayersData[victim.ID].hp, GetMaxHP(victim));
    LastAttackerIds[victim.ID] := shooter.ID;
    LastTargetIds[shooter.ID] := victim.ID;
  end;

  if PlayersData[victim.ID].hp > victim.Health then
    result := 0
  else if PlayersData[victim.ID].hp > 0 then
    result := victim.Health - PlayersData[victim.ID].hp
  else
    result := 9999;
end;

procedure HandleOnKitPickup(player: TActivePlayer; kit: TActiveMapObject);
begin
  if PlayersData[player.ID].hp < player.Health then
    SetPlayerHP(player, player.Health);
end;

procedure HandleOnKill(var killer, victim: TActivePlayer; bulletId: Byte);
var
  exp: Integer;
begin
  UseNova(victim, killer);

  if killer.ID <> victim.ID then
  begin
    UseSoulReap(killer);
    UseChronoTap(killer);

    exp := KillExp(killer, victim);

    ExpGainedIndicator(killer, victim, exp);

    killer.WriteConsole(
      'You killed ' + victim.Name +
      ' (Lv' + IntToStr(PlayersData[victim.ID].level) + ')' +
      ' for ' + IntToStr(exp) + ' exp',
      GREEN);

    victim.WriteConsole(
      'You are killed by ' + killer.Name +
      ' (Lv' + IntToStr(PlayersData[killer.ID].level) + ')',
      RED);

    GrantExp(killer, exp);
  end;
end;

procedure HandleWeaponChange(player: TActivePlayer; primary, secondary: TPlayerWeapon);
var
  ticksSinceSpawn, timestopTicks: Integer;
begin
  ticksSinceSpawn := LastTick - PlayersData[player.ID].spawnTick;

  if (ticksSinceSpawn > 60 * 5) and
     (PlayersData[player.ID].hp > 0) and
     (primary.WType <> WTYPE_NOWEAPON) then
  begin
    timestopTicks := UseTimestop(player);
    if (timestopTicks > 0) then
    begin
      timestopActive := true;
      if (LastTick + timestopTicks > timestopEndTick) then
        timestopEndTick := LastTick + timestopTicks;
      Game.TickThreshold := TICK_THRESHOLD_NORMAL / 2;
    end;
  end;
end;

procedure HandleOnClockTick(ticks: Integer);
var
  i: Integer;
begin
  // Cooldown calculation needs this to be up to date
  LastTick := ticks;

  // ASAP

  if timestopActive then
  begin
    if ticks < timestopEndTick then
      for i := 1 to 32 do
        Players[i].SetVelocity(Players[i].VelX/5.0, Players[i].VelY/5.0)
    else
    begin
      timestopActive := false;
      Game.Gravity := GRAVITY_NORMAL;
      Game.TickThreshold := TICK_THRESHOLD_NORMAL;
    end;
  end;

  for i := 1 to 32 do
    if Players[i].active then
      PlayerSpawnFix(Players[i]);

  // Scheduled

  if ticks - lastPerSecondTick >= 60 then
  begin
    lastPerSecondTick := ticks;
    for i := 1 to 32 do
      if Players[i].active then
      begin
        ProcHealingBreeze(Players[i]);
        RefreshPlayerCooldowns(Players[i]);
      end;
  end;

  if ticks - lastSaveTick >= 60 * 60 * 5 then
  begin
    SaveAllPlayers();
    lastSaveTick := ticks;
  end;
end;

procedure AddDumbBot();
var
  bot: TNewPlayer;
begin
  if Script.DebugMode then
  begin
    bot := TNewPlayer.Create;
    try
      bot.Name := 'bot';
      bot.Team := 0;
      bot.Dummy := true;
      Players.Add(bot, TJoinNormal);
    except
    finally
      bot.Free;
    end;
  end;
end;

begin
  lastSaveTick := 0;
  lastPerSecondTick := 0;
  timestopActive := false;
  timestopEndTick := 0;
end.
