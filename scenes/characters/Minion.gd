extends KinematicBody2D

################################################################################
# Constants
################################################################################

const EPSILON = 1.0

enum FSM { IDLE, WALK, ATTACK, DYING }


################################################################################
# Signals
################################################################################

signal spawn_projectile(projectile, source, target)


################################################################################
# Attributes
################################################################################

export (int) var team: int = 0
export (int) var max_health: int = 20
export (int) var power: int = 2
export (float) var attack_speed: float = 1.0  # sec
export (Global.Projectiles) var projectile: int = Global.Projectiles.NONE
export (bool) var is_caster: bool = false

export (float) var move_speed = 30.0  # pixels / sec
export (NodePath) var patrol_path = null
export (bool) var patrol_loop = false

var state: int = FSM.IDLE

var patrol_points
var patrol_index: int = 0

var health: int = max_health
var attack_target = null

var timer: float = 0.0
var velocity: Vector2 = Vector2.ZERO

onready var sprite: AnimatedSprite = $Sprite
onready var range_area: Area2D = $Range
onready var health_bar = $HealthBar


################################################################################
# Interface
################################################################################

func get_hitbox_position() -> Vector2:
    return position + $Shape.position

func set_patrol_path(path):
    patrol_path = path
    if path != null:
        patrol_points = get_node(path).curve.get_baked_points()
        patrol_index = 0


func is_alive() -> bool:
    return health > 0 and state != FSM.DYING


func take_physical_damage(damage: int):
    if state != FSM.DYING:
        health -= damage
        health_bar.set_value(health, max_health)
        if health <= 0:
            _enter_dying()


func do_attack():
    assert(attack_target != null)
    if projectile == Global.Projectiles.NONE:
        # print(name, " punches ", attack_target.name)
        attack_target.take_physical_damage(power)
    else:
        # print(name, " sends a projectile towards ", attack_target.name)
        emit_signal("spawn_projectile", projectile, self, attack_target)


################################################################################
# Event Handlers
################################################################################

func _on_Range_body_entered(body):
    if body.team == team:
        return
    if state != FSM.IDLE and state != FSM.WALK:
        return
    _enter_attack(body)


func _on_Range_body_exited(body):
    if body == attack_target:
        attack_target = null
        if state == FSM.ATTACK:
            _enter_idle()


func _on_Sprite_animation_finished():
    match state:
        FSM.ATTACK:
            # punch/attack animation finished
            do_attack()
            _enter_idle()
        FSM.DYING:
            # death animation finished
            queue_free()


################################################################################
# Life Cycle
################################################################################

func _ready():
    collision_layer = 1 << team
    collision_mask = ~collision_layer
    health = max_health
    health_bar.set_value(health, max_health)
    sprite.animation = Global.ANIM_IDLE
    set_patrol_path(patrol_path)


func _process(delta: float):
    match state:
        FSM.IDLE:
            _process_idle(delta)
        FSM.WALK:
            _process_walk(delta)
        FSM.ATTACK:
            _process_attack(delta)
        _:
            pass


func _physics_process(delta: float):
    match state:
        FSM.WALK:
            _physics_process_walk(delta)
        _:
            pass


func _enter_idle():
    # print(name, " --> IDLE")
    state = FSM.IDLE
    sprite.animation = Global.ANIM_IDLE
    attack_target = null


func _enter_walk():
    # print(name, " --> WALK")
    state = FSM.WALK
    sprite.animation = Global.ANIM_WALK


func _enter_attack(target: Node2D):
    # print(name, " --> ATTACK")
    assert(target.team != team)
    state = FSM.ATTACK
    attack_target = target
    sprite.animation = Global.ANIM_CAST if is_caster else Global.ANIM_PUNCH
    sprite.flip_h = target.position.x < position.x
    timer = attack_speed


func _enter_dying():
    # print(name, " --> DYING")
    state = FSM.DYING
    health = 0
    power = 0
    move_speed = 0
    patrol_path = null
    patrol_points = null
    attack_target = null
    velocity = Vector2.ZERO
    sprite.animation = Global.ANIM_DEATH


################################################################################
# Helper Functions
################################################################################

func _process_idle(delta):
    timer -= delta
    if timer > 0:
        return
    delta = -timer
    timer = 0
    var target = _check_for_enemies()
    if target != null:
        _enter_attack(target)
        return _process_attack(delta)
    if patrol_path != null:
        _enter_walk()


func _process_walk(_delta):
    pass


func _process_attack(delta: float):
    assert(timer > 0)
    timer -= delta
    if timer <= 0:
        timer = 0
        # ready to attack
        delta = -timer
        _enter_idle()
        _process_idle(delta)


func _physics_process_walk(delta):
    if !patrol_path:
        return
    var target = patrol_points[patrol_index]
    velocity = _aim(target)
    if velocity == Vector2.ZERO:
        patrol_index += 1
        if patrol_index >= patrol_points.size():
            patrol_index = 0
            if not patrol_loop:
                patrol_path = null
                patrol_points = null
                _enter_idle()
                return
        target = patrol_points[patrol_index]
        velocity = _aim(target)
    sprite.flip_h = velocity.x < 0
    velocity *= move_speed * delta
    var _collision = move_and_collide(velocity)


func _aim(target: Vector2) -> Vector2:
    var dx = target.x - position.x
    var dy = target.y - position.y
    if dx < -EPSILON:
        if dy < -EPSILON:
            return Global.NORTHWEST
        if dy > EPSILON:
            return Global.SOUTHWEST
        return Global.WEST
    if dx > EPSILON:
        if dy < -EPSILON:
            return Global.NORTHEAST
        if dy > EPSILON:
            return Global.SOUTHEAST
        return Global.EAST
    if dy < -EPSILON:
        return Global.NORTH
    if dy > EPSILON:
        return Global.SOUTH
    return Vector2.ZERO


func _check_for_enemies():
    for target in range_area.get_overlapping_bodies():
        if target == self or target.team == team or not target.is_alive():
            continue
        return target
    return null
