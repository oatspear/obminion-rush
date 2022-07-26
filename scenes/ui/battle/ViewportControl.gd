extends ColorRect

################################################################################
# Constants
################################################################################

const SCN_AREA_SELECTOR = preload("res://scenes/ui/battle/AreaSelector.tscn")
const INVISIBLE = 0
const TRANSLUCENT = 0.25

################################################################################
# Signals
################################################################################

signal area_selection_canceled()
signal area_selected(i, x, y)

################################################################################
# Variables
################################################################################

onready var selecting_area: bool = false
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
    area.rect_global_position.x = pos.x - (w / 2.0)
    area.rect_global_position.y = pos.y - (h / 2.0)
    area.rect_size.x = w
    area.rect_size.y = h


func show_area_selector(i: int):
    color.a = TRANSLUCENT
    selecting_area = true
    area_selectors[i].visible = true


func show_area_selectors():
    color.a = TRANSLUCENT
    selecting_area = true
    for area in area_selectors:
        area.visible = true


func hide_area_selector(i: int):
    color.a = INVISIBLE
    selecting_area = false
    area_selectors[i].visible = false
    for sel in area_selectors:
        if sel.visible:
            color.a = TRANSLUCENT
            selecting_area = true
            return


func hide_area_selectors():
    color.a = INVISIBLE
    selecting_area = false
    for area in area_selectors:
        area.visible = false


################################################################################
# Events
################################################################################

func _on_AreaSelector_gui_input(event, i):
    if not selecting_area:
        return
    if event is InputEventMouseButton:
        # if event.button_index != BUTTON_LEFT
        if not event.pressed:
            return
        hide_area_selectors()
        var coords = event.global_position
        emit_signal("area_selected", i, coords.x, coords.y)
    elif event is InputEventScreenTouch:
        # if event.index != 0
        if not event.pressed:
            return
        hide_area_selectors()
        var coords = event.position
        emit_signal("area_selected", i, coords.x, coords.y)


func _on_ViewportControl_gui_input(event):
    if not selecting_area:
        return
    if event is InputEventMouseButton:
        # if event.button_index != BUTTON_LEFT
        if not event.pressed:
            return
        hide_area_selectors()
        emit_signal("area_selection_canceled")
    elif event is InputEventScreenTouch:
        # if event.index != 0
        if not event.pressed:
            return
        hide_area_selectors()
        emit_signal("area_selection_canceled")
