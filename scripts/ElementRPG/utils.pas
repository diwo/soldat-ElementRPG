unit Utils;

uses
  SkillsInfo,
  Math,
  Globals;

procedure Debug(msg: String);
begin
  WriteLn(msg);
  if Script.DebugMode then
    Players.WriteConsole(msg, RED);
end;

function Split(str: String; delim: Char): Array of String;
var
  arrLen, tokenIdx, i: Integer;
begin
  arrLen := 1;

  for i := 1 to Length(str) do
    if str[i] = delim then
      arrLen := arrLen + 1;

  SetLength(result, arrLen);

  tokenIdx := 0;
  result[0] := '';

  for i := 1 to Length(str) do
  begin
    if str[i] = delim then
    begin
      tokenIdx := tokenIdx + 1;
      result[tokenIdx] := '';
    end
    else
      result[tokenIdx] := result[tokenIdx] + str[i];
  end;
end;

function FloatToStrTrunc(num: Double; decimalPlaces: Integer): String;
var
  str: String;
  dotidx: Integer;
begin
  str := FloatToStr(num);
  dotidx := Pos('.', str);
  if dotidx > 0 then
    result := Copy(str, 1, dotidx - 1) + '.' + Copy(str, dotidx + 1, decimalPlaces)
  else
    result := str;
end;

function ErrToStr(err: TErrorType): String;
begin
  case err of
    ErNoError: result := 'ErNoError';
    erCannotImport: result := 'erCannotImport';
    erInvalidType: result := 'erInvalidType';
    ErInternalError: result := 'ErInternalError';
    erInvalidHeader: result := 'erInvalidHeader';
    erInvalidOpcode: result := 'erInvalidOpcode';
    erInvalidOpcodeParameter: result := 'erInvalidOpcodeParameter';
    erNoMainProc: result := 'erNoMainProc';
    erOutOfGlobalVarsRange: result := 'erOutOfGlobalVarsRange';
    erOutOfProcRange: result := 'erOutOfProcRange';
    ErOutOfRange: result := 'ErOutOfRange';
    erOutOfStackRange: result := 'erOutOfStackRange';
    ErTypeMismatch: result := 'ErTypeMismatch';
    erUnexpectedEof: result := 'erUnexpectedEof';
    erVersionError: result := 'erVersionError';
    ErDivideByZero: result := 'ErDivideByZero';
    ErMathError: result := 'ErMathError';
    erCouldNotCallProc: result := 'erCouldNotCallProc';
    erOutofRecordRange: result := 'erOutofRecordRange';
    erOutOfMemory: result := 'erOutOfMemory';
    erException: result := 'erException';
    erNullPointerException: result := 'erNullPointerException';
    erNullVariantError: result := 'erNullVariantError';
    erInterfaceNotSupported: result := 'erInterfaceNotSupported';
    erCustomError: result := 'erCustomError';
  else
    result := 'UnknownError';
  end;
end;

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
    WTYPE_AK74: result := 3;
    WTYPE_STEYRAUG: result := 20;
    WTYPE_SPAS12: result := 5;
    WTYPE_RUGER77: result := 2;
    WTYPE_M79: result := 5;
    WTYPE_BARRETT: result := 1;
    WTYPE_M249: result := 200;
    WTYPE_MINIGUN: result := 4;
    WTYPE_USSOCOM: result := 1;
    WTYPE_KNIFE: result := 0;
    WTYPE_CHAINSAW: result := 200;
    WTYPE_LAW: result := 10;
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

function RankInterpolate(fromVal, toVal: Single; skill, curRank: Integer): Single;
begin
  result := InterpolateLinear(fromVal, toVal, 1, SkillMaxRanks[skill], curRank);
end;

procedure PrintRankInterpolate(fromVal, toVal: Single; skill: Integer);
var
  i: Integer;
begin
  Debug('Skill table for ' + SkillNames[skill] + ':');
  for i := 1 to SkillMaxRanks[skill] do
    Debug(
      'Rank ' + IntToStr(i) + ': ' +
      FloatToStrTrunc(RankInterpolate(fromVal, toVal, skill, i), 2));
end;

function DistancePlayers(p1, p2: TActivePlayer): Single;
begin
  result := Distance(p1.x, p1.y, p2.x, p2.y);
end;

function RayCastPlayers(p1, p2: TActivePlayer): Boolean;
begin
  result := Map.RayCast(
    p1.x, p1.y - 10, p2.x, p2.y - 10,
    true, false, false, true, 0);
end;

procedure CreateBulletAngled(
  player: TActivePlayer; style: Byte;
  angle, speed, spawnDist, dmgMult: Single);
var
  x, y, vx, vy: Single;
begin
  x := player.x;
  y := player.y - 10;
  vx := cos(angle) * speed;
  vy := sin(angle) * speed;
  x := x + vx / speed * spawnDist;
  y := y + vy / speed * spawnDist;
  Map.CreateBullet(x, y, vx, vy, dmgMult, style, player);
end;

procedure CreateBulletTargeted(
  var player, target, owner: TActivePlayer; style: Byte;
  speed, spawnDist, dmgMult, spread: Single);
var
  offx, offy, x1, y1, x2, y2: Single;
  dist, vx, vy : Single;
begin
  offx := Random(-100, 100) * spread / 100.0;
  offy := Random(-100, 100) * spread / 100.0;

  x1 := player.x;
  y1 := player.y - 10;
  x2 := target.x + offx;
  y2 := target.y + offy - 10;

  dist := Distance(x1, y1, x2, y2);
  vx := (x2 - x1) * speed / dist;
  vy := (y2 - y1) * speed / dist;

  x1 := x1 + vx / speed * spawnDist;
  y1 := y1 + vy / speed * spawnDist;

  Map.CreateBullet(x1, y1, vx, vy, dmgMult, style, player);
end;

procedure FillScreen(player: TActivePlayer; layer, duration: Integer; color: Longint);
begin
  player.BigText(layer, 'X', duration, color, 50, -3650, -5200);
end;

