extends HBoxContainer

################################################################################
# Constants
################################################################################

const ICON_MELEE = preload("res://assets/ui/melee-icon.png")
const ICON_RANGED = preload("res://assets/ui/ranged-icon.png")
const ICON_CASTER = preload("res://assets/ui/caster-icon.png")
const ICON_HEALER = preload("res://assets/ui/healer-icon.png")
const ICON_TANK = preload("res://assets/ui/shield-icon.png")

################################################################################
# Variables
################################################################################

var value: int = Global.Roles.MELEE

onready var icon = $Icon

################################################################################
# Interface
################################################################################

func set_role(role: int):
    assert(role in Global.Roles.values())
    value = role
    match role:
        Global.Roles.MELEE:
            icon.texture = ICON_MELEE
        Global.Roles.RANGED:
            icon.texture = ICON_RANGED
        Global.Roles.CASTER:
            icon.texture = ICON_CASTER
        Global.Roles.HEALER:
            icon.texture = ICON_HEALER
        Global.Roles.TANK:
            icon.texture = ICON_TANK
        _:
            icon.texture = ICON_MELEE
