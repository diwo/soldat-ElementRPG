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

procedure TCPCmdPlayers(var args: Array of String);
var
  showSkills: Boolean;
  i, j: Integer;
  ids: Array of Integer;
begin
  showSkills := false;
  try
    if LowerCase(args[1]) = 'skills' then
      showSkills := true;
  except end;

  ids := GetActivePlayersSorted();

  WriteLn('Current players:');
  for i := 0 to Length(ids) - 1 do
  begin
    WriteLn(IntToStr(ids[i]) + ': ' + GetPlayerSummary(ids[i]));
    if showSkills then
      for j := 1 to SKILLS_LENGTH do
        if PlayersData[ids[i]].skillRanks[j] > 0 then
          WriteLn('  ' + GetPlayerSkill(Players[ids[i]], j));
  end;
end;

procedure TCPCmdBoost(var args: Array of String);
var
  playerNum, targetLevel, i: Integer;
begin
  try
    targetLevel := StrToInt(args[2]);

    if LowerCase(args[1]) = 'all' then
    begin
      for i := 1 to 32 do
        BoostPlayer(Players[i], targetLevel);
      WriteLn('You boosted everyone to level ' + IntToStr(targetLevel));
    end
    else begin
      playerNum := StrToInt(args[1]);

      if Players[playerNum].Active and Players[playerNum].human then
      begin
        BoostPlayer(Players[playerNum], targetLevel);
        WriteLn(
          'You boosted ' + Players[playerNum].Name +
          ' to level ' + IntToStr(targetLevel));
      end;
    end;
    exit;
  except end;

  WriteLn('Usage:');
  WriteLn('  /boost PLAYER_NUM TARGET_LEVEL');
  WriteLn('  /boost all TARGET_LEVEL');
end;

procedure HandleOnTCPMessage(ip: string; port: Word; text: string);
var
  args: Array of String;
begin
  args := Split(text, ' ');

  case LowerCase(args[0]) of
    '/help': TCPCmdHelp();
    '/players': TCPCmdPlayers(args);
    '/boost': TCPCmdBoost(args);
  end;
end;
