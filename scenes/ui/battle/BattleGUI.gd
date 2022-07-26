extends CanvasLayer

################################################################################
# Signals
################################################################################

signal area_selected(i, x, y)
signal spawn_minion_requested(i)

################################################################################
# Variables
################################################################################

onready var status_bar = $Margin/V/StatusBar
onready var viewport_control = $Margin/V/ViewportControl
onready var action_bar = $Margin/V/ActionBar

################################################################################
# Interface
################################################################################

func set_player_gold(value: int):
    status_bar.set_player_gold(value)


func set_action_button(
    i: int,
    unit: int,
    frames: SpriteFrames,
    cost: int,
    cooldown: float = 0.0
):
    action_bar.buttons[i].set_unit(unit, frames, cost)
    if cooldown > 0:
        action_bar.buttons[i].start_cooldown(cooldown)


################################################################################
# Events
################################################################################

func _on_ViewportControl_area_selected(i, x, y):
    emit_signal("area_selected", i, x, y)


func _on_ActionBar_button_selected(i):
    var unit = action_bar.buttons[i].unit_type
    emit_signal("spawn_minion_requested", unit)
