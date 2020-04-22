unit Help;

uses
  SkillsInfo,
  Globals;

procedure HelpGeneral(var player: TActivePlayer);
begin
  player.WriteConsole('Available commands:', ORANGE);
  player.WriteConsole('/assign  - Manually assign skill points', WHITE);
  player.WriteConsole('/refund  - Refund skill points', WHITE);
  player.WriteConsole('/auto    - Automatically distribute skill points', WHITE);
  player.WriteConsole('/players - Show player levels and skills', WHITE);
  player.WriteConsole('/rebirth - Temporarily set your level to 1', GREY);
end;

procedure HelpAssign(var player: TActivePlayer);
begin
  player.WriteConsole('Usage: /assign NUM[:POINTS] [[NUM:POINTS]...]', ORANGE);
end;

procedure HelpRebirth(var player: TActivePlayer);
begin
  player.WriteConsole('The /rebirth command resets your level to 1 until you rejoin the server', WHITE);
  player.WriteConsole('Your level will be restored next time you connect to the server', WHITE);
  player.WriteConsole('Exp you earn this session will be added to your normal character', WHITE);
  player.WriteConsole('Type ''/rebirth YES'' if you want to continue', LIGHTGREY);
end;

procedure HelpGust(var player: TActivePlayer);
begin
  player.WriteConsole('Usage: /gust up|down|left|right', ORANGE);
  player.WriteConsole('Give yourself a boost from a gust of wind.', WHITE);
  player.WriteConsole('Bind the command to a taunt for quick access.', WHITE);
end;

procedure HelpCmd(var player: TActivePlayer; cmd: String);
begin
  case LowerCase(cmd) of
    'assign': HelpAssign(player);
    'rebirth': HelpRebirth(player);
    'gust': HelpGust(player);
  else
    HelpGeneral(player);
  end;
end;
