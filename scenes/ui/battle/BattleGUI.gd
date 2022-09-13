extends CanvasLayer

################################################################################
# Constants
################################################################################

const AREA_SELECTOR_WIDTH = 48
const AREA_SELECTOR_HEIGHT = 32

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

var last_action_button: int = -1

################################################################################
# Interface
################################################################################

func get_num_action_buttons() -> int:
    return len(action_bar.buttons)


func set_player_gold(value: int, refresh_buttons: bool = true):
    status_bar.set_player_gold(value)
    if refresh_buttons:
        refresh_button_status()


func set_player_score(value: int):
    status_bar.set_player_score(value)


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
    # print("refresh buttons")
    var player_gold = status_bar.get_player_gold()
    for button in action_bar.buttons:
        if button.cost <= player_gold and not button.is_on_cooldown():
            button.enable()
        else:
            button.disable()


func ensure_area_selectors(n: int):
    while len(viewport_control.area_selectors) < n:
        viewport_control.add_area_selector()
    viewport_control.hide_area_selectors()


func set_area_selector(i: int, pos: Vector2):
    ensure_area_selectors(i+1)
    viewport_control.set_area_selector(i, pos, AREA_SELECTOR_WIDTH, AREA_SELECTOR_HEIGHT)


func select_target_area():
    action_bar.visible = false
    viewport_control.show_area_selectors()


func hide_all_inputs():
    action_bar.visible = false
    viewport_control.hide_area_selectors()


################################################################################
# Events
################################################################################

func _on_ViewportControl_area_selected(i, x, y):
    # print("area selected: ", i)
    viewport_control.hide_area_selectors()
    action_bar.visible = true
    emit_signal("area_selected", i, x, y)


func _on_ViewportControl_area_selection_canceled():
    # print("area selection canceled")
    viewport_control.hide_area_selectors()
    action_bar.visible = true


func _on_ActionBar_button_selected(i):
    # print("button pressed: ", i)
    last_action_button = i
    var unit_type = action_bar.buttons[i].unit_type
    emit_signal("spawn_minion_requested", i, unit_type)


func _on_ActionBar_button_ready(i):
    # print("button ready: ", i)
    var player_gold = status_bar.get_player_gold()
    var button = action_bar.buttons[i]
    assert(not button.is_on_cooldown())
    if button.cost <= player_gold:
        button.enable()
    else:
        button.disable()
