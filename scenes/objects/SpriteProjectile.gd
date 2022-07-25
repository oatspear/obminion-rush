extends Sprite

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

var source: WeakRef
var target: WeakRef
var travel_distance: float = 0.0

onready var state = FSM.TRAVEL


################################################################################
# Interface
################################################################################

func do_effect():
    if target == null:
        return
    var t = target.get_ref()
    if t:
        t.take_physical_damage(power, source)


################################################################################
# Life Cycle
################################################################################

func _ready():
    # requires: set initial position
    # requires: set target
    # requires: set power
    var t = target.get_ref()
    if not t:
        queue_free()
        return
    var p: Vector2 = t.position
    travel_distance = position.distance_to(p) + 16
    var dx = p.x - position.x
    var dy = p.y - position.y
    if abs(dx) >= abs(dy):
        # more horizontal than vertical
        frame = 1
        flip_h = dx < 0
        flip_v = dy > 0
    else:
        # more vertical than horizontal
        flip_h = dx > 0
        flip_v = dy > 0


func _physics_process(delta):
    if state != FSM.TRAVEL:
        return
    var t = target.get_ref()
    if not t:
        state = FSM.IMPACT
        return
    var p = t.position
    if position.distance_to(p) < 1:
        state = FSM.IMPACT
    else:
        var vel: Vector2 = p - position
        vel = vel.normalized() * speed * delta
        position += vel
        travel_distance -= vel.length()
        if travel_distance <= 0 and state == FSM.TRAVEL:
            state = FSM.IMPACT
            target = null


func _process(delta):
    if state == FSM.IMPACT:
        state = FSM.DECAY
        do_effect()
    if state == FSM.DECAY:
        decay -= delta
        if decay <= 0:
            queue_free()
