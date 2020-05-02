unit Skills;

uses
  Players,
  SkillsInfo,
  Cooldowns,
  DamageIndicator,
  Help,
  Utils,
  Globals;

procedure UseMagicMissile(var player, victim: TActivePlayer);
var
  rank, cd, cdRemain: Integer;
  speed, spread, damage: Single;
  collision: Boolean;
begin
  rank := PlayersData[player.ID].skillRanks[SKILL_MAGIC_MISSILE];

  if (rank > 0) and (player <> victim) then
  begin
    cd := CooldownTicks(player, SKILL_MAGIC_MISSILE);
    cdRemain := CooldownTicksRemaining(player, SKILL_MAGIC_MISSILE);
    collision := RayCastPlayers(player, victim);

    if (cdRemain <= 0) and (not collision) and (DistancePlayers(player, victim) > 200) then
    begin
      SetSkillLastUsedTick(player, SKILL_MAGIC_MISSILE);
      speed := RankInterpolate(20, 30, SKILL_MAGIC_MISSILE, rank);
      spread := RankInterpolate(30, 20, SKILL_MAGIC_MISSILE, rank);
      damage := RankInterpolate(5, 8, SKILL_MAGIC_MISSILE, rank);

      CreateBulletTargeted(player, victim, player, BULLET_LAW, speed, 100, damage, spread);

      player.WriteConsole(
        'You activated Magic Missile against ' + victim.name +
        ' (cooldown ' + IntToStr(cd/60) + 's)', WHITE);
    end;
  end;
end;

procedure UseMagneticGrasp(var player, victim: TActivePlayer);
var
  rank, cd, cdRemain: Integer;
  maxStrength, strength, dist: Single;
  collision: Boolean;
begin
  rank := PlayersData[player.ID].skillRanks[SKILL_MAGNETIC_GRASP];

  if (rank > 0) and (player <> victim) and (victim.Primary.WType <> WTYPE_CHAINSAW) then
  begin
    cd := CooldownTicks(player, SKILL_MAGNETIC_GRASP);
    cdRemain := CooldownTicksRemaining(player, SKILL_MAGNETIC_GRASP);
    collision := RayCastPlayers(player, victim);
    dist := Distance(player.x, player.y, victim.x, victim.y);

    if (cdRemain <= 0) and (not collision) and (dist > 120) then
    begin
      SetSkillLastUsedTick(player, SKILL_MAGNETIC_GRASP);

      maxStrength := RankInterpolate(4, 8, SKILL_MAGNETIC_GRASP, rank);
      strength := dist / 50.0;
      if strength > maxStrength then
        strength := maxStrength;

      victim.SetVelocity(
        (player.x - victim.x) / dist * strength,
        (player.y - victim.y) / dist * strength);

      player.WriteConsole(
        'You activated Magnetic Grasp against ' + victim.name +
        ' (cooldown ' + IntToStr(cd/60) + 's)', WHITE);

      victim.WriteConsole(
        'You are pulled by ' + player.name + '''s Magnetic Grasp', LIGHTGREY);
    end;
  end;
end;

procedure UseBlindingFlash(var player, victim: TActivePlayer);
var
  rank, cd, cdRemain, duration: Integer;
  collision: Boolean;
begin
  rank := PlayersData[player.ID].skillRanks[SKILL_BLINDING_FLASH];

  if (rank > 0) and (player <> victim) and (victim.human) then
  begin
    cd := CooldownTicks(player, SKILL_BLINDING_FLASH);
    cdRemain := CooldownTicksRemaining(player, SKILL_BLINDING_FLASH);
    collision := RayCastPlayers(player, victim);

    if (cdRemain <= 0) and (not collision) then
    begin
      SetSkillLastUsedTick(player, SKILL_BLINDING_FLASH);
      duration := Trunc(RankInterpolate(2*60, 3*60, SKILL_BLINDING_FLASH, rank));

      FillScreen(victim, LAYER_FLASH, duration, WHITE);

      player.WriteConsole(
        'You activated Blinding Flash against ' + victim.name +
        ' (cooldown ' + IntToStr(cd/60) + 's)', WHITE);

      victim.WriteConsole(
        'You are blinded by ' + player.name + '''s Blinding Flash', LIGHTGREY);
    end;
  end;
end;

procedure UseShock(var player, victim: TActivePlayer);
var
  rank, cd, cdRemain: Integer;
  range, dist: Single;
  weap: TNewWeapon;
begin
  rank := PlayersData[player.ID].skillRanks[SKILL_SHOCK];

  if (rank > 0) and
     (player <> victim) and
     (victim.human) and
     (victim.Primary.WType <> WTYPE_NOWEAPON) then
  begin
    cd := CooldownTicks(player, SKILL_SHOCK);
    cdRemain := CooldownTicksRemaining(player, SKILL_SHOCK);
    range := RankInterpolate(100, 200, SKILL_SHOCK, rank);
    dist := Distance(player.x, player.y, victim.x, victim.y);

    if (cdRemain <= 0) and (dist < range) then
    begin
      SetSkillLastUsedTick(player, SKILL_SHOCK);

      weap := TNewWeapon.Create();
      try
        weap.WType := WTYPE_NOWEAPON;
        victim.ForceWeapon(TWeapon(weap), player.secondary);
      except finally
        weap.Free();
      end;

      player.WriteConsole(
        'You activated Shock to disarm ' + victim.name +
        ' (cooldown ' + IntToStr(cd/60) + 's)', WHITE);

      victim.WriteConsole(
        'You are disarmed by ' + player.name + '''s Shock', LIGHTGREY);
    end;
  end;
end;

procedure UseStormCharge(var player, victim: TActivePlayer);
var
  rank, cd, cdRemain: Integer;
  collision: Boolean;
  dist: Single;
begin
  rank := PlayersData[player.ID].skillRanks[SKILL_STORM_CHARGE];

  if (rank > 0) and (player <> victim) and (victim.Primary.WType <> WTYPE_CHAINSAW) then
  begin
    cd := CooldownTicks(player, SKILL_STORM_CHARGE);
    cdRemain := CooldownTicksRemaining(player, SKILL_STORM_CHARGE);
    collision := RayCastPlayers(player, victim);
    dist := Distance(player.x, player.y, victim.x, victim.y);

    if (cdRemain <= 0) and (not collision) and (dist > 200) then
    begin
      SetSkillLastUsedTick(player, SKILL_STORM_CHARGE);

      player.SetVelocity(0, 0);
      player.Move(
        victim.x + (player.x - victim.x) * 25 / dist,
        victim.y + (player.y - victim.y) * 25 / dist);

      player.WriteConsole(
        'You activated Storm Charge against ' + victim.name +
        ' (cooldown ' + IntToStr(cd/60) + 's)', WHITE);
    end;
  end;
end;

procedure UseNova(var player, killer: TActivePlayer);
var
  rank, cd, cdRemain, numProj, i: Integer;
  speed, damage: Single;
begin
  rank := PlayersData[player.ID].skillRanks[SKILL_NOVA];

  if (rank > 0) and (player <> killer) then
  begin
    cd := CooldownTicks(player, SKILL_NOVA);
    cdRemain := CooldownTicksRemaining(player, SKILL_NOVA);

    if cdRemain <= 0 then
    begin
      SetSkillLastUsedTick(player, SKILL_NOVA);

      numProj := Trunc(RankInterpolate(20, 40, SKILL_NOVA, rank));
      speed := RankInterpolate(10, 15, SKILL_NOVA, rank);
      damage := RankInterpolate(10, 30, SKILL_NOVA, rank);

      for i := 0 to numProj - 1 do
        CreateBulletAngled(player, BULLET_M2, PI*2*i/numProj, speed, 20, damage);

      player.WriteConsole('You activated Nova! (cooldown ' + IntToStr(cd/60) + 's)', WHITE);
    end;
  end;
end;

function ApplyBarkskin(var player: TActivePlayer; damage: Single): Single;
var
  rank: Integer;
  reduction: Single;
begin
  result := damage;
  rank := PlayersData[player.ID].skillRanks[SKILL_BARKSKIN];

  if rank > 0 then
  begin
    reduction := RankInterpolate(5, 33.3, SKILL_BARKSKIN, rank);
    result := result * (1 - reduction/100.0);
  end;
end;

function ApplyEarthenEmbrace(var player: TActivePlayer; damage: Single): Single;
var
  rank: Integer;
  reduction: Single;
begin
  result := damage;
  rank := PlayersData[player.ID].skillRanks[SKILL_EARTHEN_EMBRACE];

  if rank > 0 then
  begin
    reduction := RankInterpolate(33.3, 100, SKILL_EARTHEN_EMBRACE, rank);
    result := result * (1 - reduction/100.0);
  end;
end;

function ApplyCrystallineShield(var player, shooter: TActivePlayer; damage: Single): Single;
var
  rank, cd, cdRemain: Integer;
  duration, ticksSinceLast: Integer;
begin
  result := damage;
  rank := PlayersData[player.ID].skillRanks[SKILL_CRYSTALLINE_SHIELD];

  if rank > 0 then
  begin
    cd := CooldownTicks(player, SKILL_CRYSTALLINE_SHIELD);
    cdRemain := CooldownTicksRemaining(player, SKILL_CRYSTALLINE_SHIELD);
    duration := Trunc(RankInterpolate(1*60, 3*60, SKILL_CRYSTALLINE_SHIELD, rank));

    if (cdRemain <= 0) and (damage >= 150) then
    begin
      SetSkillLastUsedTick(player, SKILL_CRYSTALLINE_SHIELD);

      result := 0;

      FillScreen(player, LAYER_CRYSTALLINE_SHIELD, duration, $4431F1F7);

      player.WriteConsole(
        'You activated Crystalline Shield to prevent damage' +
        ' (cooldown ' + IntToStr(cd/60) + 's)', WHITE);

      if shooter <> player then
        shooter.WriteConsole(
          player.Name + ' prevented your damage with Crystalline Shield', LIGHTGREY);
    end
    else
    begin
      ticksSinceLast := TicksSinceSkillUsed(player, SKILL_CRYSTALLINE_SHIELD);
      // may end prematurely due to ticks updating once per second
      if (ticksSinceLast >= 0) and (ticksSinceLast < duration) then
        result := 0;
    end;
  end;
end;

function ApplySmokeScreen(var player, shooter: TActivePlayer; damage: Single): Single;
var
  rank, cd, cdRemain: Integer;
  duration, ticksSinceLast: Integer;
  hpRemainingRatio, radius: Single;
  enemiesAffected: Boolean;
  i: Integer;
begin
  result := damage;

  rank := PlayersData[player.ID].skillRanks[SKILL_SMOKESCREEN];

  if rank > 0 then
  begin
    cd := CooldownTicks(player, SKILL_SMOKESCREEN);
    cdRemain := CooldownTicksRemaining(player, SKILL_SMOKESCREEN);
    hpRemainingRatio := (PlayersData[player.ID].hp - damage) / GetMaxHP(player);
    duration := Trunc(RankInterpolate(2*60, 5*60, SKILL_SMOKESCREEN, rank));

    if (cdRemain <= 0) and (player <> shooter) and
       (hpRemainingRatio > 0) and (hpRemainingRatio < 0.5) then
    begin
      radius := RankInterpolate(300, 600, SKILL_SMOKESCREEN, rank);

      enemiesAffected := false;
      for i := 1 to 32 do
      begin
        if (Players[i].active) and (i <> player.ID) then
        begin
          if DistancePlayers(player, Players[i]) <= radius then
          begin
            FillScreen(Players[i], LAYER_SMOKESCREEN_OTHER, duration, $DD888888);
            Players[i].WriteConsole(
              player.Name + ' obscured their surroundings with Smokescreen', LIGHTGREY);
            enemiesAffected := true;
          end;
        end;
      end;

      if enemiesAffected then
      begin
        SetSkillLastUsedTick(player, SKILL_SMOKESCREEN);
        FillScreen(player, LAYER_SMOKESCREEN_SELF, duration, $DD888888);

        player.WriteConsole(
          'You activated Smokescreen to hinder nearby enemy vision' +
          ' (cooldown ' + IntToStr(cd/60) + 's)', WHITE);
      end;
    end
    else
    begin
      ticksSinceLast := TicksSinceSkillUsed(player, SKILL_SMOKESCREEN);
      if (ticksSinceLast >= 0) and (ticksSinceLast < duration) then
        // does not apply to initial trigger hit
        result := result * ticksSinceLast / duration;
    end;
  end;
end;

procedure UseFlameBarrier(var player, shooter: TActivePlayer; damage: Single);
var
  rank: Integer;
  flameDamage: Single;
begin
  rank := PlayersData[player.ID].skillRanks[SKILL_FLAME_BARRIER];

  if (rank > 0) and (player <> shooter) then
  begin
    flameDamage := RankInterpolate(5, 15, SKILL_FLAME_BARRIER, rank);
    flameDamage := InterpolateQuadratic(flameDamage/5, flameDamage, 0, 300, damage);

    Map.CreateBullet(
      shooter.x, shooter.y,
      shooter.VelX * 2, shooter.VelY * 2,
      flameDamage, BULLET_FLAME, player);
  end;
end;

procedure ProcHealingBreeze(player: TActivePlayer);
var
  rank: Integer;
  amount: Single;
begin
  rank := PlayersData[player.ID].skillRanks[SKILL_HEALING_BREEZE];

  if (rank > 0) and (player.Alive) then
  begin
    amount := RankInterpolate(5, 20, SKILL_HEALING_BREEZE, rank);
    if PlayersData[player.ID].hp < GetMaxHP(player) then
    begin
      SetPlayerHP(player, PlayersData[player.ID].hp + amount);
      DamageHealedIndicator(player, amount);

      if PlayersData[player.ID].hp > GetMaxHP(player) then
        SetPlayerHP(player, GetMaxHP(player));
    end;
  end;
end;

procedure UseBloodRitual(player: TActivePlayer);
var
  rank, cd, cdRemain: Integer;
  hpPercent, hpAmount: Single;
begin
  rank := PlayersData[player.ID].skillRanks[SKILL_BLOOD_RITUAL];

  if (rank > 0) and (player.Primary.WType <> WTYPE_NOWEAPON) then
  begin
    cd := CooldownTicks(player, SKILL_BLOOD_RITUAL);
    cdRemain := CooldownTicksRemaining(player, SKILL_BLOOD_RITUAL);

    if cdRemain <= 0 then
    begin
      SetSkillLastUsedTick(player, SKILL_BLOOD_RITUAL);
      hpPercent := RankInterpolate(5, 20, SKILL_BLOOD_RITUAL, rank);

      player.Primary.Ammo := GetWeaponMaxAmmo(player.Primary.WType);
      if player.Secondary.WType <> WTYPE_NOWEAPON then
      begin
        player.ForceWeapon(player.Secondary, player.Primary);
        player.Primary.Ammo := GetWeaponMaxAmmo(player.Primary.WType);
        player.ForceWeapon(player.Secondary, player.Primary);
      end;

      hpAmount := GetMaxHP(player) * hpPercent / 100.0;
      if PlayersData[player.ID].hp + hpAmount < GetMaxHP(player) then
        SetPlayerHP(player, PlayersData[player.ID].hp + hpAmount)
      else
      begin
        hpAmount := GetMaxHP(player) - PlayersData[player.ID].hp;
        SetPlayerHP(player, GetMaxHP(player));
      end;

      DamageHealedIndicator(player, hpAmount);

      FillScreen(player, LAYER_SOUL_REAP, 60/2, $2214C948);

      player.WriteConsole(
        'You activated Blood Ritual to replenish ammo and some health' +
        ' (cooldown ' + IntToStr(cd/60) + 's)', WHITE);
    end;
  end;
end;

procedure UseSoulReap(player: TActivePlayer);
var
  rank, cd, cdRemain: Integer;
  ticksSinceLast, reduction, i: Integer;
begin
  rank := PlayersData[player.ID].skillRanks[SKILL_SOUL_REAP];

  if rank > 0 then
  begin
    cd := CooldownTicks(player, SKILL_SOUL_REAP);
    cdRemain := CooldownTicksRemaining(player, SKILL_SOUL_REAP);

    if cdRemain <= 0 then
    begin
      ticksSinceLast := TicksSinceSkillUsed(player, SKILL_SOUL_REAP);
      SetSkillLastUsedTick(player, SKILL_SOUL_REAP);

      reduction := Trunc(RankInterpolate(5*60, 15*60, SKILL_SOUL_REAP, rank));
      if ticksSinceLast >= 0 then
        reduction := Trunc(InterpolateLinear(0, reduction, 0, 60*60, ticksSinceLast));

      for i := 1 to SKILLS_LENGTH do
        ReduceSkillCooldown(player, i, reduction);

      player.WriteConsole(
        'You activated Soul Reap to reduce skill cooldowns by ' +
        FloatToStrTrunc(reduction/60.0, 1) + 's', WHITE);
    end;
  end;
end;

function UseTimestop(var player: TActivePlayer): Integer;
var
  rank, cd, cdRemain, duration, i: Integer;
begin
  result := 0;

  rank := PlayersData[player.ID].skillRanks[SKILL_TIMESTOP];

  if rank > 0 then
  begin
    cd := CooldownTicks(player, SKILL_TIMESTOP);
    cdRemain := CooldownTicksRemaining(player, SKILL_TIMESTOP);

    if cdRemain <= 0 then
    begin
      SetSkillLastUsedTick(player, SKILL_TIMESTOP);
      duration := Trunc(RankInterpolate(1*60, 3*60, SKILL_TIMESTOP, rank));

      Game.Gravity := GRAVITY_NORMAL / 10.0;

      for i := 1 to 32 do
      begin
        Players[i].SetVelocity(Players[i].VelX/20.0, Players[i].VelY/20.0);
        FillScreen(players[i], LAYER_TIMESTOP, duration, $44E07EE6);

        if Players[i] <> player then
          Players[i].WriteConsole(
            'Time has been slowed down by ' + player.name + '''s Timestop', LIGHTGREY);
      end;

      player.WriteConsole('You activated Timestop! (cooldown ' + IntToStr(cd/60) + 's)', WHITE);

      result := duration;
    end;
  end;
end;

procedure UseGust(var player: TActivePlayer; dir: String);
var
  rank, cdRemain: Integer;
  dx, dy: Single;
begin
  rank := PlayersData[player.ID].skillRanks[SKILL_GUST];
  cdRemain := CooldownTicksRemaining(player, SKILL_GUST);

  if rank <= 0 then
    player.WriteConsole('You haven''t assigned points to Gust yet!', RED)

  else if cdRemain > 0 then
    player.WriteConsole('Gust is still on cooldown! (' + IntToStr(cdRemain/60) + 's)', RED)

  else
  begin
    dx := 0;
    dy := 0;

    case LowerCase(dir) of
      'left': dx := -5;
      'right': dx := 5;
      'up': dy := -5;
      'down': dy := 5;
    else
      HelpGust(player);
    end;

    if (dx <> 0) or (dy <> 0) then
    begin
      SetSkillLastUsedTick(player, SKILL_GUST);
      player.SetVelocity(player.VelX/2 + dx, player.VelY/2 + dy);
    end;
  end;
end;

