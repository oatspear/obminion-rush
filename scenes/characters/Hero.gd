extends "res://scenes/characters/Minion.gd"

################################################################################
# Interface
################################################################################

func take_physical_damage(damage: int, source: WeakRef):
    .take_physical_damage(damage, source)
    if state == FSM.IDLE:
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
