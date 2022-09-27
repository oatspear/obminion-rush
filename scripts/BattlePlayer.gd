extends Reference

class_name BattlePlayer

################################################################################
# Variables
################################################################################

var team: int = 0
var team_colour: int = Global.TeamColours.NONE

var hero_data: MinionData
var minion_data: Array = []

var hero_ref: WeakRef = null
var roster: Array = []

var coins: int = 0
var score: int = 0

var next_minion: int = 0


################################################################################
# Interface
################################################################################


func pick_next_minion():
    if minion_data.empty():
        next_minion = -1
        return null
    next_minion = randi() % len(minion_data)
    return minion_data[next_minion]


func get_next_minion():
    return minion_data[next_minion]