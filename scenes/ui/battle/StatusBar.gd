extends PanelContainer

################################################################################
# Variables
################################################################################

onready var gold_label = $M/H/Gold
onready var next_label = $M/H/Next

################################################################################
# Interface
################################################################################

func get_player_gold() -> int:
    return gold_label.value


func set_player_gold(value: int):
    gold_label.set_value(value)


func get_next_role() -> int:
    return next_label.value


func set_next_role(role: int):
    next_label.set_role(role)
