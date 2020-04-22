unit Weapons;

uses
  Math,
  Globals;

function GetPlayerAmmo(const player: TActivePlayer; weaponType: Integer): Integer;
begin
  if player.Primary.WType = weaponType then
    result := player.Primary.Ammo
  else
    result := -1;
end;

function WeaponDamageAdjustDeagles(
  damage: Single; ammo: Integer;
  const player: TActivePlayer): Single;
begin
  result := damage * 35;
  if ammo = 0 then result := result * 1.5;
  // Gets rid of deagles 3rd hit, normalizes flame shield behavior
  Map.CreateBullet(5000, 5000, 1, 1, 0, BULLET_KNIFE, player);
end;

function WeaponDamageAdjustAk74(damage, dist: Single): Single;
begin
  result := damage * InterpolateLinear(1, 3, 150, 450, dist);
end;

function WeaponDamageAdjustSpas(damage, dist: Single): Single;
begin
  result := damage * InterpolateLinear(1, 2.5, 200, 50, dist);
end;

function WeaponDamageAdjustM79(
  damage: Single; const player, victim: TActivePlayer): Single;
begin
  result := damage;
  if player = victim then result := result * 50;
end;

function WeaponDamageAdjustMinigun(
  damage: Single; const player, victim: TActivePlayer): Single;
begin
  result := damage;
  if player = victim then result := result * 50;
end;

function WeaponDamageAdjustSocom(
  damage: Single; const player, victim: TActivePlayer): Single;
begin
  result := damage;
  if player = victim then result := result * 20;
end;

function WeaponDamageAdjustLaw(
  damage: Single; const player, victim: TActivePlayer): Single;
begin
  result := damage;
  if player = victim then result := result * 50;
end;

function WeaponDamageAdjust(
  const player, victim: TActivePlayer;
  dist: Single; weaponType, bulletStyle: Integer;
  damage: Single): Single;
var
  dmgAdjusted: Single;
  ammo: Integer;
begin
  dmgAdjusted := damage;

  // This is the ammo in the gun after bullet has already been fired
  ammo := GetPlayerAmmo(player, weaponType);

  // Desync, gun is still full even though bullet has been fired
  if (player.human) and
     (ammo = GetWeaponMaxAmmo(weaponType)) and
     (player <> victim) then
  begin
    result := -1;
    exit;
  end;

  if (weaponType = WTYPE_EAGLE) and (bulletStyle = BULLET_M79) then
    dmgAdjusted := WeaponDamageAdjustDeagles(dmgAdjusted, ammo, player)

  else if (weaponType = WTYPE_AK74) and (bulletStyle = BULLET_SHOTGUN) then
    dmgAdjusted := WeaponDamageAdjustAk74(dmgAdjusted, dist)

  else if (weaponType = WTYPE_SPAS12) and (bulletStyle = BULLET_SHOTGUN) then
    dmgAdjusted := WeaponDamageAdjustSpas(dmgAdjusted, dist)

  else if (weaponType = WTYPE_M79) and (bulletStyle = BULLET_M79) then
    dmgAdjusted := WeaponDamageAdjustM79(dmgAdjusted, player, victim)

  else if (weaponType = WTYPE_MINIGUN) and (bulletStyle = BULLET_LAW) then
    dmgAdjusted := WeaponDamageAdjustMinigun(dmgAdjusted, player, victim)

  else if (weaponType = WTYPE_USSOCOM) and (bulletStyle = BULLET_LAW) then
    dmgAdjusted := WeaponDamageAdjustSocom(dmgAdjusted, player, victim)

  else if (weaponType = WTYPE_LAW) and (bulletStyle = BULLET_LAW) then
    dmgAdjusted := WeaponDamageAdjustLaw(dmgAdjusted, player, victim)

  else if weaponType = WTYPE_THROWNKNIFE then
    dmgAdjusted := 0;

  result := dmgAdjusted;
end;
