extends Node2D

################################################################################
# Signals
################################################################################

signal objective_captured(team)

################################################################################
# Variables
################################################################################

onready var hero_spawns = {}
onready var spawn_points = {}

onready var object_layer = $Objects

################################################################################
# Interface
################################################################################

func num_spawn_points(team: int) -> int:
    return len(spawn_points[team])


func get_spawn_points(team: int) -> Array:
    var spawns = []
    for point in spawn_points[team]:
        spawns.append(point.position)
    return spawns


func spawn_minion(minion, i: int):
    var point = spawn_points[minion.team][i]
    minion.position = point.get_random_position()
    var waypoint = point.get_waypoint()
    minion.set_waypoint(waypoint)
    object_layer.add_child(minion)


func spawn_hero(minion):
    var objective = hero_spawns[minion.team]
    minion.position = objective.position
    objective.set_hero(minion)
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
        hero_spawns[node.team] = node
        node.connect("captured", self, "_on_objective_captured", [node.team])


################################################################################
# Events
################################################################################

func _on_objective_captured(team: int):
    emit_signal("objective_captured", team)
