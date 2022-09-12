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
    match team:
        Global.Teams.RED:
            aura.modulate = Color(1.0, 0.125, 0.125, 0.5)
        Global.Teams.BLUE:
            aura.modulate = Color(0.125, 0.125, 1.0, 0.5)
        Global.Teams.GREEN:
            aura.modulate = Color(0.125, 1.0, 0.125, 0.5)
        Global.Teams.YELLOW:
            aura.modulate = Color(1.0, 1.0, 0.125, 0.5)
