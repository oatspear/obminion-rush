extends CanvasLayer

################################################################################
# Signals
################################################################################

signal area_selected(i, x, y)
signal spawn_minion_requested(i, unit_type)

################################################################################
# Variables
################################################################################

onready var status_bar = $Margin/V/StatusBar
onready var viewport_control = $Margin/V/ViewportControl
onready var action_bar = $Margin/V/ActionBar

################################################################################
# Interface
################################################################################

func get_num_action_buttons() -> int:
    return len(action_bar.buttons)


func set_player_gold(value: int, refresh_buttons: bool = true):
    status_bar.set_player_gold(value)
    if refresh_buttons:
        refresh_button_status()


func set_next_role(role: int):
    status_bar.set_next_role(role)


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


func refresh_button_status():
    var player_gold = status_bar.get_player_gold()
    for button in action_bar.buttons:
        if button.cost <= player_gold and not button.is_on_cooldown():
            button.enable()
        else:
            button.disable()


################################################################################
# Events
################################################################################

func _on_ViewportControl_area_selected(i, x, y):
    emit_signal("area_selected", i, x, y)


func _on_ActionBar_button_selected(i):
    var unit = action_bar.buttons[i].unit_type
    emit_signal("spawn_minion_requested", i, unit)


func _on_ActionBar_button_ready(i):
    var player_gold = status_bar.get_player_gold()
    var button = action_bar.buttons[i]
    assert(not button.is_on_cooldown())
    if button.cost <= player_gold:
        button.enable()
    else:
        button.disable()
