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
    TIER8,
    TIER9,
    TIER10,
    TIER11,
    TIER12
}

const HEALTH_FACTOR: int = 40


func calc_health(tier: int) -> int:
    assert(tier in HealthTiers.values())
    return HEALTH_FACTOR * tier


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
    MELEE = MINION_SIZE + 2,
    SHORT = MINION_SIZE * 2,
    MEDIUM = MINION_SIZE * 3,
    LONG = MINION_SIZE * 4
}

const ATTACK_RANGE_FACTOR: int = 8  # pixels per rank
const MELEE_ATTACK_RANGE: int = 2  # small margin over two colliding bodies

func calc_attack_range(tier: int) -> int:
    assert(tier in AttackRanges.values())
    if tier <= AttackRanges.MELEE:
        return MINION_SIZE + MELEE_ATTACK_RANGE
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

################################################################################
# Weapons and Armor
################################################################################

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


const DAMAGE_DIVISOR: int = 5

enum Projectiles { NONE, ARROW, FIRE }

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

const TEAM_STRINGS: Array = [
    "Black",
    "Red",
    "Blue",
    "Green",
    "Yellow",
]

func team2str(team: int) -> String:
    assert(team >= 0 and team < TeamColours.size())
    return TEAM_STRINGS[team]


const WORLD_MASK = 1 << TeamColours.NONE
const ALL_TEAMS_MASK = 0b11111

func get_collision_layer(team: int) -> int:
    assert(team >= 0)
    return 1 << team

func get_collision_mask(team: int) -> int:
    assert(team >= 0)
    return ALL_TEAMS_MASK ^ (1 << team)

func get_collision_mask_teams(team: int) -> int:
    assert(team > 0)
    return ALL_TEAMS_MASK ^ WORLD_MASK ^ (1 << team)


enum Roles { MELEE, RANGED, CASTER, HEALER, TANK }
