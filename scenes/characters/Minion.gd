extends KinematicBody2D

################################################################################
# Constants
################################################################################

const EPSILON = 1.0

enum FSM { IDLE, WALK, ATTACK }

################################################################################
# Attributes
################################################################################

export (int) var team: int = 0
export (int) var health: int = 20
export (Global.AttackRange) var attack_range = Global.AttackRange.MELEE

export (float) var move_speed = 30.0  # pixels / sec
export (NodePath) var patrol_path = null
export (bool) var patrol_loop = false

var state: int = FSM.IDLE

var patrol_points
var patrol_index: int = 0

var attack_target = null

var velocity: Vector2 = Vector2.ZERO

onready var sprite: AnimatedSprite = $Sprite
onready var range_area: Area2D = $Range


################################################################################
# Interface
################################################################################

func set_patrol_path(path):
    patrol_path = path
    if path != null:
        patrol_points = get_node(path).curve.get_baked_points()
        patrol_index = 0


################################################################################
# Event Handlers
################################################################################

func _on_Range_body_entered(body):
    if not body is KinematicBody2D:
        return
    if body.team == team:
        return
    _enter_attack(body)


func _on_Range_body_exited(body):
    if body == attack_target:
        attack_target = null
        if state == FSM.ATTACK:
            state = FSM.IDLE


################################################################################
# Life Cycle
################################################################################

func _ready():
    sprite.animation = "default"
    set_patrol_path(patrol_path)
    $Range/Area.shape.radius = Global.MELEE_RANGE + attack_range


func _process(delta):
    match state:
        FSM.IDLE:
            _process_idle(delta)
        FSM.WALK:
            _process_walk(delta)
        _:
            pass


func _physics_process(delta):
    match state:
        FSM.WALK:
            _physics_process_walk(delta)
        _:
            pass


func _enter_attack(target: Node2D):
    assert(target.team != team)
    state = FSM.ATTACK
    attack_target = target
    sprite.animation = "punch"
    sprite.flip_h = target.position.x < position.x


################################################################################
# Helper Functions
################################################################################

func _process_idle(_delta):
    if patrol_path != null:
        state = FSM.WALK
        sprite.animation = "walk"


func _process_walk(_delta):
    pass


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
