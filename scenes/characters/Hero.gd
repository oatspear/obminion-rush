extends "res://scenes/characters/Minion.gd"

################################################################################
# Variables
################################################################################

var _tolerance: int = 0

################################################################################
# Interface
################################################################################

func take_final_damage(damage: int, typed: int, source: WeakRef):
    .take_final_damage(damage, typed, source)
    if state == FSM.WALK:
        _tolerance += 1
    if state == FSM.IDLE or _tolerance > 3:
        _tolerance = 0
        var m = source.get_ref()
        if not m:
            return
        _enter_pursuit(m)

################################################################################
# Life Cycle
################################################################################

func _ready():
    var aura = $Aura
    aura.modulate = Global.get_team_colour(team_colour)
