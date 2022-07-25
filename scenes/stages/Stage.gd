extends Node2D

################################################################################
# Signals
################################################################################

signal objective_captured(team)

################################################################################
# Variables
################################################################################

onready var spawn_points = {}

onready var object_layer = $Objects

################################################################################
# Interface
################################################################################

func num_spawn_points(team: int) -> int:
    return len(spawn_points[team])


func spawn_minion(minion, team: int, i: int):
    var point = spawn_points[team][i]
    minion.position = point.get_random_position()
    var waypoint = point.get_waypoint()
    minion.set_waypoint(waypoint)
    object_layer.add_child(minion)

func spawn_object(obj):
    object_layer.add_child(obj)


################################################################################
# Life Cycle
################################################################################

func _ready():
    for p in $SpawnPoints.get_children():
        var points = spawn_points.get(p.team)
        if not points:
            points = []
            spawn_points[p.team] = points
        points.append(p)
    for node in $Objectives.get_children():
        node.connect("destroyed", self, "_on_objective_destroyed", [node.team])


################################################################################
# Events
################################################################################

func _on_objective_destroyed(team: int):
    emit_signal("objective_captured", team)
