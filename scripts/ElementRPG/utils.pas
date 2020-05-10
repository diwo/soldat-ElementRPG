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
  owner, target: TActivePlayer; style: Byte;
  angle, speed, spawnDist, dmgMult: Single);
var
  x, y, vx, vy: Single;
begin
  x := target.x;
  y := target.y - 10;
  vx := cos(angle) * speed;
  vy := sin(angle) * speed;
  x := x + vx / speed * spawnDist;
  y := y + vy / speed * spawnDist;
  Map.CreateBullet(x, y, vx, vy, dmgMult, style, owner);
end;

procedure CreateBulletTargeted(
  var player, target, owner: TActivePlayer; style: Byte;
  speed, spawnDist, dmgMult, spread: Single);
var
  offx, offy, x1, y1, x2, y2: Single;
  dist, vx, vy : Single;
begin
  offx := RandomFixed(-100, 100) * spread / 100.0;
  offy := RandomFixed(-100, 100) * spread / 100.0;

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

