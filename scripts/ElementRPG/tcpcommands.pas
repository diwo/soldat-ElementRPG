unit TCPCommands;

uses
  Players,
  SkillsInfo,
  Utils;

procedure TCPCmdHelp();
begin
  WriteLn('Available commands:');
  WriteLn('/players');
end;

procedure TCPCmdPlayers();
var
  i, j: Integer;
  ids: Array of Integer;
begin
  ids := GetActivePlayersSorted();

  WriteLn('Current players:');
  for i := 0 to Length(ids) - 1 do
  begin
    WriteLn(GetPlayerSummary(ids[i]));
    for j := 1 to SKILLS_LENGTH do
      if PlayersData[ids[i]].skillRanks[j] > 0 then
        WriteLn('  ' + GetPlayerSkill(Players[ids[i]], j));
  end;
end;

procedure HandleOnTCPMessage(ip: string; port: Word; text: string);
var
  args: Array of String;
begin
  args := Split(text, ' ');

  case LowerCase(args[0]) of
    '/help': TCPCmdHelp();
    '/players': TCPCmdPlayers();
  end;
end;
