extends Node2D

################################################################################
# Variables
################################################################################

export (float) var cooldown: float = 10.0
export (Global.Abilities) var special_attack: int = Global.Abilities.NONE

var timer: float = 0.0

onready var this_minion = get_parent()

################################################################################
# Event Handling
################################################################################


func _ready():
    this_minion.connect("attacking", self, "_on_minion_attacking")


func _process(delta: float):
    if timer > 0.0:
        timer = max(0.0, timer - delta)
        this_minion.set_energy(cooldown - timer, cooldown)


func _on_minion_attacking(target):
    if timer <= 0.0:
        this_minion.spawn_area_effect(special_attack, target.position)
        this_minion.attack_overriden = true
        timer = cooldown
