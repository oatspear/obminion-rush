extends Node2D

################################################################################
# Constants
################################################################################

const SCN_MINION: PackedScene = preload("res://scenes/characters/Minion.tscn")
const SCN_ARROW = preload("res://scenes/objects/Arrow.tscn")
const SCN_FIREBALL = preload("res://scenes/objects/Fireball.tscn")

################################################################################
# Variables
################################################################################

export (Resource) var minion1_data
export (Resource) var minion2_data

var minion1
var minion2

onready var spawn1: Position2D = $Spawn1
onready var spawn2: Position2D = $Spawn2

################################################################################
# Initialization
################################################################################

func _ready():
    minion1 = SCN_MINION.instance()
    minion1.team = Global.Teams.BLUE
    _spawn_minion(minion1, minion1_data, spawn1, spawn2)
    minion2 = SCN_MINION.instance()
    minion2.team = Global.Teams.RED
    _spawn_minion(minion2, minion2_data, spawn2, spawn1)


################################################################################
# Helper Functions
################################################################################

func _spawn_minion(minion, data: MinionData, point: Position2D, waypoint: Position2D):
    minion.base_data = data
    minion.connect("spawn_projectile", self, "_on_spawn_projectile")
    minion.position = point.position
    minion.set_waypoint(waypoint.position)
    add_child(minion)


func _on_spawn_projectile(projectile, source, target):
    match projectile:
        Global.Projectiles.ARROW:
            _spawn_projectile(SCN_ARROW, source, target)
        Global.Projectiles.FIRE:
            _spawn_projectile(SCN_FIREBALL, source, target)
        _:
            pass


func _spawn_projectile(scene, source, target):
    var obj = scene.instance()
    obj.team = source.team
    obj.source = weakref(source)
    obj.position = source.position
    obj.target = target.position
    obj.power = source.power
    add_child(obj)
