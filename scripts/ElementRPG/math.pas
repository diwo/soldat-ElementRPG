unit Math;

const LN2 = 0.69314718055994530941;
const E = 2.71828182845904523536;
const EPS = 0.000000000001;

// approximation via arithmetic-geometric mean
// https://en.wikipedia.org/wiki/Natural_logarithm#High_precision
function Ln(x: Double): Double;
var
  m: Integer;
  a, b, c: Double;
begin
  m := 0;
  a := 1;
  b := 65536/x;
  while x * a <= b do
  begin
    m := m + 1;
    a := a * 2;
  end;
  a := 4/x/a;
  b := 1;

  while Abs(a - b) > EPS do
  begin
    c := a;
    a := (a + b) / 2
    b := sqrt(c) * sqrt(b);
  end;

  result := PI/a/2 - m * ln2;
end;

function LogN(b, x: Double): Double;
begin
  result := Ln(x) / Ln(b);
end;

// via reduction of y to 0 < y < 1
// then calculate as product of square roots since x^(1/2) = sqrt(x)
function Pow(x, y: Double): Double;
var
  rem, pow2, xroot: Double;
begin
  if y = 0 then
    result := 1
  else if y < 0 then
    result := 1 / Pow(x, -y)
  else if y > 1 then
    result := Pow(x*x, y/2)
  else
  begin
    rem := y;
    pow2 := 1;
    xroot := x;
    result := 1;
    while rem > EPS do
    begin
      if rem >= pow2 then
      begin
        result := result * xroot;
        rem := rem - pow2;
      end;
      pow2 := pow2 / 2;
      xroot := Sqrt(xroot);
    end;
  end;
end;

function Max(x, y: Double): Double;
begin
  if x > y
    then result := x
    else result := y;
end;

function Min(x, y: Double): Double;
begin
  if x < y
    then result := x
    else result := y;
end;

function Bound(low, high, val: Single): Single;
begin
  if low > high then
    result := Bound(high, low, val)
  else
    result := Max(low, Min(high, val));
end;

function Interpolate(fromVal, toVal, ratio: Single): Single;
begin
  result := (toVal - fromVal) * ratio + fromVal;
end;

function InterpolateLinear(fromVal, toVal, low, high, x: Single): Single;
var
  ratio: Single;
begin
  ratio := (Bound(low, high, x) - low) / (high - low);
  result := Interpolate(fromVal, toVal, ratio);
end;

function InterpolateQuadratic(fromVal, toVal, low, high, x: Single): Single;
var
  ratio, a, b: Single;
begin
  a := Bound(low, high, x) - low;
  b := high - low;
  ratio := (a * a) / (b * b);
  result := Interpolate(fromVal, toVal, ratio);
end;
