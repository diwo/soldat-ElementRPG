unit SkillsInfo;

const
  // Offensive
  SKILL_MAGIC_MISSILE = 1;
  SKILL_MAGNETIC_GRASP = 2;
  SKILL_BLINDING_FLASH = 3;
  SKILL_SHOCK = 4;
  SKILL_STORM_CHARGE = 5;
  SKILL_NOVA = 6;
  // Defensive
  SKILL_BARKSKIN = 7;
  SKILL_EARTHEN_EMBRACE = 8;
  SKILL_CRYSTALLINE_SHIELD = 9;
  SKILL_SMOKESCREEN = 10;
  SKILL_FLAME_BARRIER = 11;
  SKILL_HEALING_BREEZE = 12;
  // Utility
  SKILL_BLOOD_RITUAL = 13;
  SKILL_SOUL_REAP = 14;
  SKILL_TIMESTOP = 15;
  SKILL_GUST = 16;

const
  SKILLS_LENGTH = 16;

var
  SkillNames: Array[1..SKILLS_LENGTH] of String;
  SkillMaxRanks: Array[1..SKILLS_LENGTH] of Integer;
  SkillCooldownLow: Array[1..SKILLS_LENGTH] of Integer;
  SkillCooldownHigh: Array[1..SKILLS_LENGTH] of Integer;
  SkillShowCooldown: Array[1..SKILLS_LENGTH] of Boolean;
  SkillPassive: Array[1..SKILLS_LENGTH] of Boolean;
  SkillInfo: Array[1..SKILLS_LENGTH] of String;

procedure InitSkill(
  skill: Integer;
  name: String;
  maxRank, cdLow, cdHigh: Integer;
  showCooldown, passive: Boolean;
  info: String);
begin
  SkillNames[skill] := name;
  SkillMaxRanks[skill] := maxRank;
  SkillCooldownLow[skill] := cdLow * 60;
  SkillCooldownHigh[skill] := cdHigh * 60;
  SkillShowCooldown[skill] := showCooldown;
  SkillPassive[skill] := passive;
  SkillInfo[skill] := info;
end;

procedure InitSkillsInfo();
begin
  // Offsensive
  InitSkill(SKILL_MAGIC_MISSILE,      'MagicMissile',      10, 20,  5,  true,  true,  'Shoot missiles on damage');
  InitSkill(SKILL_MAGNETIC_GRASP,     'MagneticGrasp',     10, 30,  10, true,  true,  'Pull enemies towards you on damage');
  InitSkill(SKILL_BLINDING_FLASH,     'BlindingFlash',     10, 90,  45, true,  true,  'Blind enemies on damage');
  InitSkill(SKILL_SHOCK,              'Shock',             10, 90,  45, true,  true,  'Disarm nearby enemies on damage');
  InitSkill(SKILL_STORM_CHARGE,       'StormCharge',       10, 90,  30, true,  true,  'Teleport to enemies on damage');
  InitSkill(SKILL_NOVA,               'Nova',              10, 90,  30, true,  true,  'Create an explosion on death');
  // Defensive
  InitSkill(SKILL_BARKSKIN,           'Barkskin',          10, 0,   0,  false, true,  'Reduce damage taken');
  InitSkill(SKILL_EARTHEN_EMBRACE,    'EarthenEmbrace',    3,  0,   0,  false, true,  'Greatly reduce self damage');
  InitSkill(SKILL_CRYSTALLINE_SHIELD, 'CrystallineShield', 10, 120, 60, true,  true,  'Periodically negate burst damage');
  InitSkill(SKILL_SMOKESCREEN,        'Smokescreen',       10, 120, 60, true,  true,  'Hinder nearby enemies visibility on low health');
  InitSkill(SKILL_FLAME_BARRIER,      'FlameBarrier',      10, 0,   0,  false, true,  'Burn enemy on damage taken');
  InitSkill(SKILL_HEALING_BREEZE,     'HealingBreeze',     10, 0,   0,  false, true,  'Gradually regenerate health');
  // Utility
  InitSkill(SKILL_BLOOD_RITUAL,       'BloodRitual',       10, 60,  12, true,  true,  'Replenish ammo and some health on kill');
  InitSkill(SKILL_SOUL_REAP,          'SoulReap',          10, 10,  10, false, true,  'Reduce cooldowns on kill');
  InitSkill(SKILL_TIMESTOP,           'Timestop',          10, 120, 45, true,  true,  'Slow time on weapon change');
  InitSkill(SKILL_GUST,               'Gust',              10, 30,  5,  true,  false, 'Active skill to boost movement. See ''/help gust''');
end;

begin
  InitSkillsInfo;
end.
