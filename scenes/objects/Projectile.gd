extends KinematicBody2D

################################################################################
# Constants
################################################################################

enum FSM { TRAVEL, IMPACT, DECAY }


################################################################################
# Variables
################################################################################

export (int) var power: int = 1
export (float) var speed: float = 120  # pixels / sec
export (float) var decay: float = 0.125  # secs

var target: Vector2 = Vector2()

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
    # requires: set collision layer and mask
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
    var vel = target - position
    vel = vel.normalized() * speed * delta
    if abs(vel.x) < 1 and abs(vel.y) < 1:
        state = FSM.IMPACT
        collision_target = null
    var col = move_and_collide(vel)
    if col != null:
        state = FSM.IMPACT
        collision_target = col.collider


func _process(delta):
    if state == FSM.IMPACT:
        state = FSM.DECAY
        do_effect()
    if state == FSM.DECAY:
        decay -= delta
        if decay <= 0:
            queue_free()
