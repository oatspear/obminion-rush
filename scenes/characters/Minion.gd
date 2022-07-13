extends KinematicBody2D

################################################################################
# Constants
################################################################################

const EPSILON = 1.0

enum FSM { IDLE, WALK }

################################################################################
# Attributes
################################################################################

export (float) var move_speed = 30.0  # pixels / sec
export (NodePath) var patrol_path
export (bool) var patrol_loop = false

var state: int = FSM.IDLE

var patrol_points
var patrol_index: int = 0

var velocity: Vector2 = Vector2.ZERO

onready var sprite: AnimatedSprite = $Sprite


################################################################################
# Interface
################################################################################

func set_patrol_path(path: NodePath):
    patrol_path = path
    if path:
        patrol_points = get_node(path).curve.get_baked_points()
        patrol_index = 0


################################################################################
# Life Cycle
################################################################################

func _ready():
    set_patrol_path(patrol_path)


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
    if position.distance_to(target) < EPSILON:
        patrol_index += 1
        if patrol_index >= patrol_points.size():
            patrol_index = 0
            if not patrol_loop:
                patrol_path = null
                patrol_points = null
                velocity = Vector2.ZERO
                return
        target = patrol_points[patrol_index]
    velocity = (target - position).normalized() * move_speed
    if abs(velocity.x) < EPSILON:
        velocity.x = 0
    if abs(velocity.y) < EPSILON:
        velocity.y = 0
    velocity = move_and_slide(velocity)
    sprite.flip_h = velocity.x < 0
