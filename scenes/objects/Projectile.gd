extends KinematicBody2D

################################################################################
# Constants
################################################################################

enum FSM { TRAVEL, IMPACT, DECAY }

const TRAVEL_MARGIN = 8  # pixels

################################################################################
# Variables
################################################################################

export (Global.Teams) var team: int = Global.Teams.NONE
export (int) var power: int = 1
export (float) var speed: float = 120  # pixels / sec
export (float) var decay: float = 0.125  # secs

var target: Vector2 = Vector2()
var travel_distance: float = 0.0

onready var sprite: Sprite = $Sprite
onready var state = FSM.TRAVEL
onready var collision_target = null


################################################################################
# Interface
################################################################################

func do_effect():
    if collision_target != null:
        collision_target.take_physical_damage(power)


################################################################################
# Life Cycle
################################################################################

func _ready():
    # requires: set initial position
    # requires: set target
    # requires: set power
    # collision_layer = Global.get_collision_layer(team)
    collision_mask = Global.get_collision_mask(team)
    travel_distance = position.distance_to(target) + TRAVEL_MARGIN
    var dx = target.x - position.x
    var dy = target.y - position.y
    if abs(dx) >= abs(dy):
        # more horizontal than vertical
        sprite.frame = 1
        sprite.flip_h = dx < 0
        sprite.flip_v = dy > 0
    else:
        # more vertical than horizontal
        sprite.flip_h = dx > 0
        sprite.flip_v = dy > 0


func _physics_process(delta):
    if state != FSM.TRAVEL:
        return
    var vel: Vector2 = target - position
    vel = vel.normalized() * speed * delta
    var col = move_and_collide(vel)
    if col == null:
        travel_distance -= vel.length()
    else:
        state = FSM.IMPACT
        collision_target = col.collider
        travel_distance -= col.travel.length()
    if travel_distance <= 0 and state == FSM.TRAVEL:
        state = FSM.IMPACT
        collision_target = null


func _process(delta):
    if state == FSM.IMPACT:
        state = FSM.DECAY
        do_effect()
    if state == FSM.DECAY:
        decay -= delta
        if decay <= 0:
            queue_free()
