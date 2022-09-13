extends Node

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

enum SpeedLevels {
    TIER1 = 8,
    TIER2 = 12,
    TIER3 = 16,
    TIER4 = 20,
    TIER5 = 24,
    TIER6 = 28,
    TIER7 = 32
}

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

const ATTACK_RANGE_MULTIPLIER: int = 16  # pixels per rank
const MELEE_ATTACK_RANGE: int = 12  # not quite 16

enum AttackCooldowns {
    LONGEST = 2000,   # ms
    LONG = 1750,      # ms
    MEDIUM = 1500,    # ms
    SHORT = 1250,     # ms
    SHORTEST = 1000,  # ms
}

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

const ANIM_IDLE = "default"
const ANIM_WALK = "walk"
const ANIM_CAST = "attack"
const ANIM_ATTACK = "attack"
const ANIM_DEATH = "death"

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
