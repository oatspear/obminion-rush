extends Node2D

################################################################################
# Constants
################################################################################

const SCN_MINION: PackedScene = preload("res://scenes/characters/Minion.tscn")
const SCN_ARROW = preload("res://scenes/objects/Arrow.tscn")
const SCN_FIREBALL = preload("res://scenes/objects/Fireball.tscn")

const MINION_DATA_PATH = "res://data/minions/%s/Tier%d/%s.tres"

const TEAM1 = 1
const TEAM2 = 2

################################################################################
# Variables
################################################################################

#export (Resource) var minion1_data
export (Global.TeamColours) var minion1_colour = Global.TeamColours.BLUE
export (Global.Races) var minion1_race = Global.Races.NONE
export (int, 1, 5) var minion1_tier = 1
export (String) var minion1_name = "Minion"
export (int, 1, 10) var num_minion1 = 1

#export (Resource) var minion2_data
export (Global.TeamColours) var minion2_colour = Global.TeamColours.RED
export (Global.Races) var minion2_race = Global.Races.NONE
export (int, 1, 5) var minion2_tier = 1
export (String) var minion2_name = "Minion"
export (int, 1, 10) var num_minion2 = 1

onready var spawn1: Position2D = $Spawn1
onready var spawn2: Position2D = $Spawn2

################################################################################
# Initialization
################################################################################

func _ready():
    var data = load(MINION_DATA_PATH % _minion1_params())
    for i in range(0, num_minion1):
        var minion = SCN_MINION.instance()
        minion.team = TEAM1
        minion.team_colour = minion1_colour
        _spawn_minion(minion, data, spawn1, spawn2)
    data = load(MINION_DATA_PATH % _minion2_params())
    for i in range(0, num_minion2):
        var minion = SCN_MINION.instance()
        minion.team = TEAM2
        minion.team_colour = minion2_colour
        _spawn_minion(minion, data, spawn2, spawn1)


################################################################################
# Helper Functions
################################################################################


func _minion1_params() -> Array:
    var race_name = Global.race2str(minion1_race)
    return [race_name, minion1_tier, minion1_name]


func _minion2_params() -> Array:
    var race_name = Global.race2str(minion2_race)
    return [race_name, minion2_tier, minion2_name]


func _spawn_minion(minion, data: MinionData, point: Position2D, waypoint: Position2D):
    minion.base_data = data
    minion.connect("spawn_projectile", self, "_on_spawn_projectile")
    minion.position.y = point.position.y
    var dx = randi() % 10 - 5
    minion.position.x = point.position.x + dx
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
