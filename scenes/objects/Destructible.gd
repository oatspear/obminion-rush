extends StaticBody2D

################################################################################
# Signals
################################################################################

signal destroyed()

################################################################################
# Attributes
################################################################################

export (int) var team: int = -1
export (int) var max_health: int = 20

var health: int = max_health

onready var health_bar = $HealthBar


################################################################################
# Interface
################################################################################

func get_hitbox_position() -> Vector2:
    return position + $Shape.position


func is_alive() -> bool:
    return health > 0


func take_physical_damage(damage: int):
    if health > 0:
        health -= damage
        health_bar.set_value(health, max_health)
        if health <= 0:
            emit_signal("destroyed")


################################################################################
# Life Cycle
################################################################################

func _ready():
    health = max_health
    health_bar.set_value(health, max_health)
