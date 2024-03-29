extends KinematicBody2D

################################################################################
# Constants
################################################################################

enum FSM { TRAVEL, IMPACT, DECAY }

const TRAVEL_MARGIN = 8  # pixels

################################################################################
# Variables
################################################################################

export (int) var team: int = 0
export (int) var power: int = 1
export (Global.WeaponTypes) var weapon_type: int = Global.WeaponTypes.NORMAL
export (Global.DamageTypes) var damage_type: int = Global.DamageTypes.PHYSICAL
export (float) var speed: float = 120  # pixels / sec
export (float) var decay: float = 0.125  # secs

var source: WeakRef
var target: Vector2 = Vector2()
var travel_distance: float = 0.0

onready var sprite: Sprite = $Sprite
onready var state = FSM.TRAVEL
onready var collision_target: WeakRef = null


################################################################################
# Interface
################################################################################

func do_effect():
    if collision_target != null:
        var t = collision_target.get_ref()
        if t and t.team != team:
            t.take_attack(power, damage_type, source)
            if weapon_type == Global.WeaponTypes.SPLASH:
                var splash = Global.calc_aura_damage_bonus(power)
                for other in t._get_melee_allies():
                    other.take_damage(splash, damage_type, source)


################################################################################
# Life Cycle
################################################################################

func _ready():
    # requires: set initial position
    # requires: set target
    # requires: set power
    # collision_layer = Global.get_collision_layer(team)
    collision_mask = Global.get_collision_mask_teams(team)
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
        collision_target = weakref(col.collider)
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
