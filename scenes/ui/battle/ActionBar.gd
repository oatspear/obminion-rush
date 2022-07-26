extends HBoxContainer

################################################################################
# Signals
################################################################################

signal button_selected(i)

################################################################################
# Variables
################################################################################

onready var buttons: Array = [
    $ActionButton1,
    $ActionButton2,
    $ActionButton3,
]

################################################################################
# Events
################################################################################

func _on_ActionButton1_pressed():
    emit_signal("button_selected", 0)


func _on_ActionButton2_pressed():
    emit_signal("button_selected", 1)


func _on_ActionButton3_pressed():
    emit_signal("button_selected", 2)
