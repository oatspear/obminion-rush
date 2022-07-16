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

const UNIT_HITBOX: int = 8  # pixels (length)

enum Projectiles { NONE, ARROW, FIRE }

const ANIM_IDLE = "default"
const ANIM_WALK = "walk"
const ANIM_CAST = "cast"
const ANIM_PUNCH = "punch"
const ANIM_DEATH = "death"
const ANIM_SNOOZE = "hit"

const MIN_UNIT_COST = 1
const MAX_UNIT_COST = 5
