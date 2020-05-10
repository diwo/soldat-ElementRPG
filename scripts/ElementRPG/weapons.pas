unit Weapons;

uses
  Math,
  Globals;

function WeapIdToStr(weapId: Integer): String;
begin
  case weapId of
    WTYPE_EAGLE: result := 'Deagles';
    WTYPE_MP5: result := 'MP5';
    WTYPE_AK74: result := 'Ak74';
    WTYPE_STEYRAUG: result := 'AUG';
    WTYPE_SPAS12: result := 'Spas';
    WTYPE_RUGER77: result := 'Ruger';
    WTYPE_M79: result := 'M79';
    WTYPE_BARRETT: result := 'Barrett';
    WTYPE_M249: result := 'M249';
    WTYPE_MINIGUN: result := 'Minigun';
    WTYPE_USSOCOM: result := 'USSOCOM';
    WTYPE_KNIFE: result := 'Knife';
    WTYPE_CHAINSAW: result := 'Chainsaw';
    WTYPE_LAW: result := 'LAW';
    WTYPE_FLAMER: result := 'Flamer';
    WTYPE_BOW: result := 'Bow';
    WTYPE_BOW2: result := 'Bow2';
    WTYPE_M2: result := 'M2';
    WTYPE_NOWEAPON: result := 'Hands';
    WTYPE_FRAGGRENADE: result := 'Grenade';
    WTYPE_CLUSTERGRENADE: result := 'ClusterGrenade';
    WTYPE_CLUSTER: result := 'Cluster';
    WTYPE_THROWNKNIFE: result := 'KnifeThrow';
  else
    result := 'Unknown';
  end;
end;

function BulletStyleToStr(bulletStyle: Integer): String;
begin
  case bulletStyle of
    BULLET_PLAIN: result := 'Plain';
    BULLET_GRENADE: result := 'Grenade';
    BULLET_SHOTGUN: result := 'Shotgun';
    BULLET_M79: result := 'M79';
    BULLET_FLAME: result := 'Flame';
    BULLET_PUNCH: result := 'Punch';
    BULLET_ARROW: result := 'Arrow';
    BULLET_FLAMEARROW: result := 'FlameArrow';
    BULLET_CUT: result := 'Cut';
    BULLET_LAW: result := 'LAW';
    BULLET_KNIFE: result := 'Knife';
    BULLET_M2: result := 'M2';
  else
    result := 'Unknown';
  end;
end;

function GetWeaponMaxAmmo(wType: Byte): Byte;
begin
  case wType of
    WTYPE_EAGLE: result := 3;
    WTYPE_MP5: result := 80;
    WTYPE_AK74: result := 5;
    WTYPE_STEYRAUG: result := 40;
    WTYPE_SPAS12: result := 5;
    WTYPE_RUGER77: result := 2;
    WTYPE_M79: result := 5;
    WTYPE_BARRETT: result := 1;
    WTYPE_M249: result := 200;
    WTYPE_MINIGUN: result := 4;
    WTYPE_USSOCOM: result := 1;
    WTYPE_KNIFE: result := 0;
    WTYPE_CHAINSAW: result := 200;
    WTYPE_LAW: result := 6;
    WTYPE_FLAMER: result := 0;
    WTYPE_BOW: result := 0;
    WTYPE_BOW2: result := 0;
    WTYPE_M2: result := 0;
    WTYPE_NOWEAPON: result := 0;
    WTYPE_FRAGGRENADE: result := 0;
    WTYPE_CLUSTERGRENADE: result := 0;
    WTYPE_CLUSTER: result := 0;
    WTYPE_THROWNKNIFE: result := 0;
  else
    result := 0;
  end;
end;

function RandomWeaponPrimary(): Integer;
begin
  result := RandomFixed(1, 10);
end;

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
  result := Min(damage, 5.0) * 25;
  if ammo = 0 then result := result * 2;
  // Gets rid of deagles 3rd hit, normalizes flame shield behavior
  Map.CreateBullet(5000, 5000, 1, 1, 0, BULLET_KNIFE, player);
end;

function WeaponDamageAdjustAk74(damage, dist: Single): Single;
begin
  result := damage * InterpolateLinear(1, 4, 150, 450, dist);
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
  if player = victim then result := result * 40;
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
