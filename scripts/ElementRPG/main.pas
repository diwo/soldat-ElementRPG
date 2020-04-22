uses
  HUD,
  Players,
  Skills,
  Commands,
  TCPCommands,
  Utils;

function OnCommandHandler(player: TActivePlayer; cmd: String): Boolean;
begin
  result := HandleOnCommand(player, cmd);
end;

procedure OnSpeakHandler(player: TActivePlayer; text: String);
begin
  HandleOnSpeakCommand(player, text);
end;

function OnBeforeRespawnHandler(player: TActivePlayer): Byte;
begin
  result := HandleOnBeforeRespawn(player);
end;

function OnDamageHandler(shooter, victim: TActivePlayer; damage: Single; bulletId: Byte): Single;
begin
  result := HandleOnDamage(shooter, victim, damage, bulletId);
end;

procedure OnKitPickupHandler(player: TActivePlayer; kit: TActiveMapObject);
begin
  HandleOnKitPickup(player, kit);
end;

procedure OnKillHandler(killer, victim: TActivePlayer; bulletId: Byte);
begin
  HandleOnKill(killer, victim, bulletId);
end;

procedure OnWeaponChangeHandler(player: TActivePlayer; primary, secondary: TPlayerWeapon);
begin
  HandleWeaponChange(player, primary, secondary);
end;

procedure OnJoinHandler(player: TActivePlayer; team: TTeam);
begin
  InitPlayer(player);
  ResetPlayerCooldowns(player);

  player.OnCommand := @OnCommandHandler;
  player.OnSpeak := @OnSpeakHandler;
  player.OnBeforeRespawn := @OnBeforeRespawnHandler;
  player.OnDamage := @OnDamageHandler;
  player.OnKitPickup := @OnKitPickupHandler;
  player.OnKill := @OnKillHandler;
  player.OnWeaponChange := @OnWeaponChangeHandler;
end;

procedure OnLeaveHandler(player: TActivePlayer; kicked: Boolean);
begin
  SavePlayer(player);
  ClearPlayerFromAttackerTarget(player);
  RefreshPlayersList(player.ID);
end;

procedure OnClockTickHandler(ticks: Integer);
begin
  HandleOnClockTick(ticks);
end;

procedure OnTCPMessageHandler(ip: string; port: Word; text: string);
begin
  HandleOnTCPMessage(ip, port, text);
end;

function OnUnhandledExceptionHandler(
  errorCode: TErrorType; message, unitName, functionName: String;
  row, col: Cardinal): Boolean;
begin
  Debug('Unhandled exception [' + ErrToStr(errorCode) + ']: ' + message);
  Debug(
    'in ' + unitName + '(' + IntToStr(row) + ',' + IntToStr(col) + ')' +
    ' [' + functionName + ']');
  result := false;
end;

begin
  Script.OnUnhandledException := @OnUnhandledExceptionHandler;
  Game.OnJoin := @OnJoinHandler;
  Game.OnLeave := @OnLeaveHandler;
  Game.OnClockTick := @OnClockTickHandler;
  Game.OnTCPMessage := @OnTCPMessageHandler;
end.

