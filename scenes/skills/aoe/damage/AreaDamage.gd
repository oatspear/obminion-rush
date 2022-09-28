extends "res://scenes/skills/aoe/AreaEffect.gd"

################################################################################
# Variables
################################################################################

export (int) var power: int = 0
export (Global.DamageTypes) var damage_type: int = Global.DamageTypes.PHYSICAL

################################################################################
# Placeholder Methods
################################################################################


func _start_effect():
    for target in get_overlapping_bodies():
        if target.team == team or not target.is_alive():
            continue
        var _d = target.take_damage(power, damage_type, source)
