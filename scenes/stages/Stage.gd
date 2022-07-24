extends Node2D

################################################################################
# Variables
################################################################################

onready var spawn_points = []

onready var object_layer = $Objects

################################################################################
# Interface
################################################################################

func num_spawn_points(team: int) -> int:
    return len(spawn_points[team])


func spawn_minion(minion, team: int, i: int):
    var point = spawn_points[team][i]
    minion.position = point.position
    var waypoint = point.get_waypoint()
    minion.set_waypoint(waypoint)
    object_layer.add_child(minion)

func spawn_object(obj):
    object_layer.add_child(obj)


################################################################################
# Life Cycle
################################################################################

func _ready():
    spawn_points = [[], []]
    for p in $SpawnPoints.get_children():
        spawn_points[p.team].append(p)
