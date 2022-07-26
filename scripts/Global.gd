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
