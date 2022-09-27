extends StaticBody2D

################################################################################
# Signals
################################################################################

signal took_damage(amount, damage_type)
signal healed_damage(amount)
signal captured(new_owner)

################################################################################
# Attributes
################################################################################

export (Global.Teams) var team: int = Global.Teams.NEUTRAL_TEAM
export (int) var max_health: int = 20

var health: int = max_health

onready var sprite = $Sprite
onready var health_bar = $HealthBar


################################################################################
# Interface
################################################################################

func is_alive() -> bool:
    return health > 0


func take_attack(damage: int, typed: int, source: WeakRef) -> int:
    return take_damage(damage, typed, source)


func take_damage(damage: int, typed: int, source: WeakRef) -> int:
    return take_final_damage(damage, typed, source)


func take_physical_damage(damage: int, source: WeakRef) -> int:
    return take_damage(damage, Global.DamageTypes.PHYSICAL, source)


func take_magic_damage(damage: int, source: WeakRef) -> int:
    return take_damage(damage, Global.DamageTypes.MAGIC, source)


func take_final_damage(damage: int, typed: int, source: WeakRef) -> int:
    if health > 0:
        health -= damage
        emit_signal("took_damage", damage, typed)
        health_bar.set_value(health, max_health)
        if health <= 0:
            emit_signal("captured", source.get_ref())
        return damage
    return 0


func heal(damage: int):
    if health < max_health:
        health += damage
        if health > max_health:
            health = max_health
        emit_signal("healed_damage", damage)
        return damage
    return 0


################################################################################
# Life Cycle
################################################################################

func _ready():
    collision_layer = Global.get_collision_layer(team)
    #collision_mask = Global.get_collision_mask(team)
    health = max_health
    health_bar.set_value(health, max_health)
