extends Control

################################################################################
# Constants
################################################################################

const SCN_AREA_SELECTOR = preload("res://scenes/ui/battle/AreaSelector.tscn")

################################################################################
# Signals
################################################################################

signal area_selected(i, x, y)

################################################################################
# Variables
################################################################################

onready var area_selectors: Array = []

################################################################################
# Interface
################################################################################

func add_area_selector() -> int:
    var i = len(area_selectors)
    var area = SCN_AREA_SELECTOR.instance()
    add_child(area)
    area.connect("gui_input", self, "_on_AreaSelector_gui_input", [i])
    area_selectors.append(area)
    return i


func set_area_selector(i: int, pos: Vector2, w: int, h: int):
    var area = area_selectors[i]
    area.rect_global_position.x = pos.x - (w / 2)
    area.rect_global_position.y = pos.y - (h / 2)
    area.rect_size.x = w
    area.rect_size.y = h


func show_area_selector(i: int):
    area_selectors[i].visible = true


func show_area_selectors():
    for area in area_selectors:
        area.visible = true


func hide_area_selector(i: int):
    area_selectors[i].visible = false


func hide_area_selectors():
    for area in area_selectors:
        area.visible = false


################################################################################
# Events
################################################################################

func _on_AreaSelector_gui_input(event, i):
    if event is InputEventMouseButton:
        # if event.button_index != BUTTON_LEFT
        if not event.pressed:
            return
        var coords = event.global_position
        emit_signal("area_selected", i, coords.x, coords.y)
    elif event is InputEventScreenTouch:
        # if event.index != 0
        if not event.pressed:
            return
        var coords = event.position
        emit_signal("area_selected", i, coords.x, coords.y)
