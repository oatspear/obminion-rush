extends Node

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

enum PowerLevels {
    TIER1 = 5,
    TIER2 = 10,
    TIER3 = 15,
    TIER4 = 20,
    TIER5 = 25,
    TIER6 = 30,
    TIER7 = 35,
    TIER8 = 40,
    TIER9 = 45,
    TIER10 = 50,
    TIER11 = 55
}

enum HealthLevels {
    TIER1 = 40,
    TIER2 = 80,
    TIER3 = 120,
    TIER4 = 160,
    TIER5 = 200,
    TIER6 = 240,
    TIER7 = 280,
    TIER8 = 320,
    TIER9 = 360,
    TIER10 = 400,
    TIER11 = 440,
    TIER12 = 480
}

################################################################################
# Movement Speed
################################################################################

enum MovementSpeeds {
    SLOWEST = 1,
    VERY_SLOW,
    SLOW,
    MEDIUM,
    FAST,
    VERY_FAST,
    FASTEST
}

const MOVE_SPEED_FACTOR: int = 4  # pixels per rank
const BASE_MOVE_SPEED: int = 8

func calc_move_speed(tier: int):
    return BASE_MOVE_SPEED + MOVE_SPEED_FACTOR * tier

################################################################################
# Attack Range
################################################################################

enum AttackRanges {
    MELEE = 1,
    CLOSE,
    SHORT,
    MEDIUM,
    LONG,
    FAR,
    VERY_FAR,
    MAXIMUM
}

const ATTACK_RANGE_FACTOR: int = 16  # pixels per rank
const MELEE_ATTACK_RANGE: int = 12  # not quite 16

func calc_attack_range(tier: int) -> int:
    if tier <= AttackRanges.MELEE:
        return MELEE_ATTACK_RANGE
    return ATTACK_RANGE_FACTOR * tier

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
    LIGHT = +2,
    MEDIUM = 0,
    HEAVY = -2
}

enum MagicResistance {
    LIGHT = +2,
    MEDIUM = 0,
    HEAVY = -2
}

const DAMAGE_DIVISOR: int = 5

enum Projectiles { NONE, ARROW, FIRE }

################################################################################
# Animations
################################################################################

const ANIM_IDLE = "default"
const ANIM_WALK = "walk"
const ANIM_CAST = "attack"
const ANIM_ATTACK = "attack"
const ANIM_DEATH = "death"

################################################################################
# Other
################################################################################

const MIN_UNIT_COST = 1
const MAX_UNIT_COST = 5

enum Teams {NONE, BLUE, RED, GREEN, YELLOW}

const WORLD_MASK = 1 << Teams.NONE
const ALL_TEAMS_MASK = 0b11111

func get_collision_layer(team: int) -> int:
    assert(team >= 0 and team < Teams.size())
    return 1 << team

func get_collision_mask(team: int) -> int:
    assert(team >= 0 and team < Teams.size())
    return ALL_TEAMS_MASK ^ (1 << team)

func get_collision_mask_teams(team: int) -> int:
    assert(team > Teams.NONE and team < Teams.size())
    return ALL_TEAMS_MASK ^ WORLD_MASK ^ (1 << team)


enum Roles { MELEE, RANGED, CASTER, HEALER, TANK }
