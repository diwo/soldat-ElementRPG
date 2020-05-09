unit Globals;

const
  ORANGE = $FFBA19;
  YELLOW = $F2E341;
  LIGHTYELLOW = $FFEBB0;
  GREEN = $21DE44;
  CYAN = $2FD7F5;
  RED = $DD1111;
  WHITE = $FFFFFF;
  LIGHTGREY = $CCCCCC;
  GREY = $A6A6A6;

const
  BULLET_PLAIN = 1;
  BULLET_GRENADE = 2;
  BULLET_SHOTGUN = 3;
  BULLET_M79 = 4;
  BULLET_FLAME = 5;
  BULLET_PUNCH = 6;
  BULLET_ARROW = 7;
  BULLET_FLAMEARROW = 8;
  BULLET_CUT = 11;
  BULLET_LAW = 12;
  BULLET_KNIFE = 13;
  BULLET_M2 = 14;

const
  // layer 1 cannot be used

  // fullscreen overlay
  LAYER_SMOKESCREEN_SELF = 10;
  LAYER_SMOKESCREEN_OTHER = 11;
  LAYER_FLASH = 12;
  LAYER_TIMESTOP = 13;
  LAYER_CRYSTALLINE_SHIELD = 14;
  LAYER_SOUL_REAP = 15;

  // hud
  LAYER_HP = 20;
  LAYER_LEVEL = 21;
  LAYER_EXP = 22;
  LAYER_LEVELUP = 23;
  // attacker/target
  LAYER_ATTACKER_LABEL = 24;
  LAYER_ATTACKER_NAME = 25;
  LAYER_ATTACKER_HP = 26;
  LAYER_TARGET_LABEL = 27;
  LAYER_TARGET_NAME = 28;
  LAYER_TARGET_HP = 29;
  // skills points
  LAYER_SP_INFO_1 = 30;
  LAYER_SP_INFO_2 = 31;

  // damage indicator
  LAYER_DAMAGE_INDICATOR = 50;

  // skills list
  LAYER_SKILLS = 100;

  // skills list
  LAYER_COOLDOWNS = 200;

  // players list
  LAYER_PLAYERS = 300;

const
  GRAVITY_NORMAL = 0.06;
  TICK_THRESHOLD_NORMAL = 60;

type
  TPlayerData = record
    player: TActivePlayer;
    level, exp, expBanked, expBoost, assignedSp: Integer;
    hp: Single;
    manual, rebirth: Boolean;
    skillRanks: Array[1..SKILLS_LENGTH] of Integer;
    spawnAmmoGiven: Boolean;
    spawnTick: Integer;
  end;

var
  PlayersData: Array[1..32] of TPlayerData;
  LastAttackerIds: Array[1..32] of Integer;
  LastTargetIds: Array[1..32] of Integer;

var
  MinSp: Integer;
  LastTick: Integer;

begin
  MinSp := 0;
  LastTick := 0;
end.
