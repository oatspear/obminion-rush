extends StaticBody2D

################################################################################
# Signals
################################################################################

signal captured()

################################################################################
# Attributes
################################################################################

export (Global.Teams) var team: int = Global.Teams.NONE
export (int) var max_health: int = 20

var health: int = max_health

onready var health_bar = $HealthBar


################################################################################
# Interface
################################################################################

func is_alive() -> bool:
    return health > 0


func take_physical_damage(damage: int, source: WeakRef):
    if health > 0:
        health -= damage
        health_bar.set_value(health, max_health)
        if health <= 0:
            emit_signal("captured")


################################################################################
# Life Cycle
################################################################################

func _ready():
    collision_layer = Global.get_collision_layer(team)
    collision_mask = Global.get_collision_mask(team)
    health = max_health
    health_bar.set_value(health, max_health)
