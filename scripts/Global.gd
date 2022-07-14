extends Node

const _UNIT_NORMAL = 0.7071067811865475

const NORTH: Vector2 = Vector2(0, -1)
const SOUTH: Vector2 = Vector2(0, 1)
const WEST: Vector2 = Vector2(-1, 0)
const EAST: Vector2 = Vector2(1, 0)
const NORTHWEST: Vector2 = Vector2(-_UNIT_NORMAL, -_UNIT_NORMAL)
const NORTHEAST: Vector2 = Vector2(_UNIT_NORMAL, -_UNIT_NORMAL)
const SOUTHWEST: Vector2 = Vector2(-_UNIT_NORMAL, _UNIT_NORMAL)
const SOUTHEAST: Vector2 = Vector2(_UNIT_NORMAL, _UNIT_NORMAL)

enum Direction { N, S, E, W, NW, NE, SW, SE }

const UNIT_HITBOX: int = 12  # pixels (length)
const MELEE_RANGE: int = UNIT_HITBOX  # circle radius

# bonus on top of MELEE_RANGE
enum AttackRange {
    MELEE = 0,
    SHORT_RANGE = UNIT_HITBOX * 3,
    LONG_RANGE = UNIT_HITBOX * 5,
}
