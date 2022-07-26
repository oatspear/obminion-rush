extends PanelContainer

################################################################################
# Variables
################################################################################

onready var gold_label = $M/H/Gold
onready var score_label = $M/H/Score
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


func get_player_score() -> int:
    return score_label.value


func set_player_score(value: int):
    score_label.set_value(value)
