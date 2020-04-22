unit SaveFiles;

uses SkillsInfo;

type
  TSaveData = record
    hwid, name: String;
    level, exp: Integer;
    manual: Boolean;
    skillRanks: Array[1..SKILLS_LENGTH] of Integer;
  end;


function SavePath(hwid: String): String;
var
  valid: Boolean;
  i: Integer;
begin
  valid := true;

  for i := 1 to Length(hwid) do
  begin
    if not (((hwid[i] >= 'A') and (hwid[i] <= 'Z')) or
            ((hwid[i] >= '0') and (hwid[i] <= '9'))) then
      valid := false;
  end;

  if valid
    then result := 'data/ElementRPG/players/' + hwid + '.sav'
    else result := '';
end;

procedure WriteSaveFile(var saveData: TSaveData);
var
  path: String;
  ini: TIniFile;
  i: Integer;
begin
  path := SavePath(saveData.hwid);

  if path <> '' then
  begin
    ini := File.CreateINI(path);

    ini.Clear;

    ini.WriteString('player', 'hwid', saveData.hwid);
    ini.WriteString('player', 'name', saveData.name);
    ini.WriteInteger('player', 'level', saveData.level);
    ini.WriteInteger('player', 'exp', saveData.exp);
    ini.WriteBool('player', 'manual', saveData.manual);

    for i := 1 to SKILLS_LENGTH do
      ini.WriteInteger('skills', SkillNames[i], saveData.skillRanks[i]);

    ini.UpdateFile;
    ini.Free;
  end;
end;

function ReadSaveFile(hwid: String): TSaveData;
var
  path: String;
  ini: TIniFile;
  saveData: TSaveData;
  i: Integer;
begin
  saveData.exp := 0;
  for i := 1 to SKILLS_LENGTH do
    saveData.skillRanks[i] := 0;

  path := SavePath(hwid);

  if path <> '' then
  begin
    ini := File.CreateINI(path);

    saveData.hwid := ini.ReadString('player', 'hwid', '');
    saveData.name := ini.ReadString('player', 'name', '');
    saveData.level := ini.ReadInteger('player', 'level', 1);
    saveData.exp := ini.ReadInteger('player', 'exp', 0);
    saveData.manual := ini.ReadBool('player', 'manual', false);

    for i := 1 to SKILLS_LENGTH do
      saveData.skillRanks[i] := ini.ReadInteger('skills', SkillNames[i], 0);

    ini.Free;
  end;

  result := saveData;
end;

