extends Node

const MINION_SIZE = 16

################################################################################
# Directions
################################################################################

const _UNIT_NORMAL = 0.7071067811865475

const NORTH: Vector2 = Vector2.UP
const SOUTH: Vector2 = Vector2.DOWN
const WEST: Vector2 = Vector2.LEFT
const EAST: Vector2 = Vector2.RIGHT
const NORTHWEST: Vector2 = Vector2(-_UNIT_NORMAL, -_UNIT_NORMAL)
const NORTHEAST: Vector2 = Vector2(_UNIT_NORMAL, -_UNIT_NORMAL)
const SOUTHWEST: Vector2 = Vector2(-_UNIT_NORMAL, _UNIT_NORMAL)
const SOUTHEAST: Vector2 = Vector2(_UNIT_NORMAL, _UNIT_NORMAL)

enum Direction { N, S, E, W, NW, NE, SW, SE }

################################################################################
# Power and Health
################################################################################

enum PowerTiers {
    TIER0 = 0,
    TIER1,
    TIER2,
    TIER3,
    TIER4,
    TIER5,
    TIER6,
    TIER7,
    TIER8,
    TIER9,
    TIER10,
    TIER11,
    TIER12
}

const POWER_FACTOR: int = 5


func calc_power(tier: int) -> int:
    assert(tier in PowerTiers.values())
    return POWER_FACTOR * tier


enum HealthTiers {
    TIER0 = 0,
    TIER1,
    TIER2,
    TIER3,
    TIER4,
    TIER5,
    TIER6,
    TIER7,
    TIER8
}

const HEALTH_FACTOR: int = 40
const HERO_HEALTH_FACTOR: int = 100


func calc_health(tier: int) -> int:
    assert(tier in HealthTiers.values())
    return HEALTH_FACTOR * tier


func calc_hero_health(tier: int) -> int:
    assert(tier in HealthTiers.values())
    return HERO_HEALTH_FACTOR * tier


################################################################################
# Movement Speed
################################################################################

const BASE_MOVE_SPEED: int = 8
const MOVE_SPEED_BONUS: int = 4

enum MovementSpeeds {
    SLOWEST = BASE_MOVE_SPEED,
    SLOW = BASE_MOVE_SPEED + MOVE_SPEED_BONUS,
    MEDIUM = BASE_MOVE_SPEED + 2 * MOVE_SPEED_BONUS,
    FAST = BASE_MOVE_SPEED + 3 * MOVE_SPEED_BONUS,
    FASTEST = BASE_MOVE_SPEED + 4 * MOVE_SPEED_BONUS
}


################################################################################
# Attack Range
################################################################################

enum AttackRanges {
    MELEE = 0,  # 12
    SHORT,      # 32
    MEDIUM,     # 40
    LONG,       # 48
    VERY_LONG,  # 56
    LONGEST     # 64
}

const ATTACK_RANGE_FACTOR: int = 8  # pixels per rank
const MELEE_ATTACK_RANGE_MARGIN: int = 2  # small margin over two colliding bodies

func calc_attack_range(tier: int) -> int:
    assert(tier in AttackRanges.values())
    if tier <= AttackRanges.MELEE:
        return MINION_SIZE + MELEE_ATTACK_RANGE_MARGIN
    return 2 * MINION_SIZE + ATTACK_RANGE_FACTOR * (tier - 1)


func get_melee_range() -> int:
    return calc_attack_range(AttackRanges.MELEE)


const AGGRO_RANGE: int = 3 * MINION_SIZE

################################################################################
# Attack Speed
################################################################################

enum AttackSpeeds {
    SLOWEST = 1,
    VERY_SLOW,
    SLOW,
    MEDIUM,
    FAST,
    VERY_FAST,
    FASTEST
}

const MIN_ATTACK_SPEED: float = 0.5  # seconds (how long the animation lasts)
const ATTACK_SPEED_TABLE: Array = [
    2.0,
    1.6,
    1.28,
    1.0,
    0.8,
    0.64,
    0.5,
]

func calc_attack_speed(tier: int) -> float:
    # just look up; formula is approximate
    return ATTACK_SPEED_TABLE[tier]


func calc_attack_speed_bonus(speed: float) -> float:
    return max(MIN_ATTACK_SPEED, speed * 0.9)


################################################################################
# Weapons and Armor
################################################################################

enum WeaponTypes { NORMAL, SPLASH }

const DAMAGE_DIVISOR: int = 5

enum DamageTypes { PHYSICAL, MAGIC, HERO }

enum ArmorTypes {
    LIGHT = 0,
    MEDIUM,
    HEAVY
}

const ARMOR_BONUSES = [+2, 0, -2]


func calc_armor_bonus(tier: int, damage: int) -> int:
    assert(tier in ArmorTypes.values())
# warning-ignore:integer_division
    return damage * ARMOR_BONUSES[tier] / DAMAGE_DIVISOR


enum MagicResistance {
    LIGHT = 0,
    MEDIUM,
    HEAVY
}

const MAGIC_RESIST_BONUSES = [+2, 0, -2]


func calc_magic_resist_bonus(tier: int, damage: int) -> int:
    assert(tier in MagicResistance.values())
# warning-ignore:integer_division
    return damage * MAGIC_RESIST_BONUSES[tier] / DAMAGE_DIVISOR


func calc_aura_damage_bonus(damage: int) -> int:
# warning-ignore:integer_division
    return damage / DAMAGE_DIVISOR


enum Projectiles { NONE, ARROW, FIRE }


################################################################################
# Abilities
################################################################################

enum Abilities {
    NONE,
    AURAS_START,
    # increase ally power
    AURA_ALL_DAMAGE_BUFF,
    AURA_PHYSICAL_DAMAGE_BUFF,
    AURA_MAGIC_DAMAGE_BUFF,
    # decrease enemy power
    AURA_DEFENSES_BUFF,
    AURA_ARMOR_BUFF,
    AURA_MAGIC_RESIST_BUFF,
    # healing over time
    AURA_HEALTH_REGENERATION,
    # lifesteal
    AURA_LIFESTEAL_MELEE,
    # increase ally movement speed
    AURA_MOVE_SPEED_BUFF,
    # increase ally attack speed
    AURA_ATTACK_SPEED_BUFF,
    # chance to dodge attacks
    AURAS_END,
    EVASION,
    SPECIAL_ATTACKS_START,
    AOE_DAMAGE_PHYSICAL,
    AOE_DAMAGE_FIRE,
    SPECIAL_ATTACKS_END,
}


func calc_lifesteal_health(damage: int) -> int:
    # 20% lifesteal
# warning-ignore:integer_division
    return damage / DAMAGE_DIVISOR


const PASSIVE_HEALTH_REGEN: int = 2  # HP/s
const EVASION_DODGE_CHANCE: float = 0.15

################################################################################
# Graphics and Animations
################################################################################

const ANIM_IDLE = "default"
const ANIM_WALK = "walk"
const ANIM_CAST = "attack"
const ANIM_ATTACK = "attack"
const ANIM_DEATH = "death"

const SPRITEFRAMES_PATH = "res://data/animation/%s/%s/%s.tres"


func load_sprite_frames(race: int, minion_name: String, team: int) -> SpriteFrames:
    assert(race in Races.values())
    assert(team in TeamColours.values())
    var race_name = race2str(race)
    var team_name = team2str(team)
    var path = SPRITEFRAMES_PATH % [race_name, minion_name, team_name]
    return load(path) as SpriteFrames


################################################################################
# Other
################################################################################

enum Races {NONE, HUMAN, ORC, UNDEAD, DEMON}

const RACE_STRINGS: Array = [
    "None",
    "Human",
    "Orc",
    "Undead",
    "Demon",
]

func race2str(race: int) -> String:
    return RACE_STRINGS[race]


const MIN_UNIT_COST = 1
const MAX_UNIT_COST = 5

enum TeamColours {
    NONE = 0,
    RED,
    BLUE,
    GREEN,
    YELLOW
}


func get_team_colour(team_colour: int):
    match team_colour:
        TeamColours.RED:
            return Color(1.0, 0.125, 0.125, 0.5)
        TeamColours.BLUE:
            return Color(0.125, 0.125, 1.0, 0.5)
        TeamColours.GREEN:
            return Color(0.125, 1.0, 0.125, 0.5)
        TeamColours.YELLOW:
            return Color(1.0, 1.0, 0.125, 0.5)


const TEAM_COLOUR_STRINGS: Array = [
    "Neutral",
    "Red",
    "Blue",
    "Green",
    "Yellow",
]

func team2str(team: int) -> String:
    assert(team >= 0 and team < TeamColours.size())
    return TEAM_COLOUR_STRINGS[team]


enum Teams {
    NEUTRAL_TEAM = 5,
    TEAM1 = 1,
    TEAM2 = 2,
    TEAM3 = 3,
    TEAM4 = 4
}


const WORLD_MASK = 1
const ALL_TEAMS_MASK = 0b111110


func get_collision_layer(team: int) -> int:
    assert(team in Teams.values())
    return 1 << team

func get_collision_mask(team: int) -> int:
    assert(team in Teams.values())
    return ALL_TEAMS_MASK ^ (1 << team) | WORLD_MASK

func get_collision_mask_teams(team: int) -> int:
    assert(team in Teams.values())
    return ALL_TEAMS_MASK ^ (1 << team)

func get_collision_mask_all_teams() -> int:
    return ALL_TEAMS_MASK

func get_collision_mask_teams_no_neutral(team: int) -> int:
    assert(team in Teams.values())
    if team == Teams.NEUTRAL_TEAM:
        return ALL_TEAMS_MASK ^ (1 << team)
    else:
        return ALL_TEAMS_MASK ^ (1 << team) ^ (1 << Teams.NEUTRAL_TEAM)


enum Roles { MELEE, RANGED, CASTER, HEALER, TANK }
