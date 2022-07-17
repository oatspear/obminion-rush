extends Node2D

const SCN_PROJECTILE = preload("res://scenes/objects/Projectile.tscn")

const FRAMES_HUMAN_R = preload("res://data/animation/Human.tres")
const FRAMES_HUMAN_G = preload("res://data/animation/HumanGreen.tres")

const SCN_HUMAN1 = preload("res://scenes/characters/Human.tscn")
const SCN_HUMAN2 = preload("res://scenes/characters/HumanArcher.tscn")
const SCN_ORC1 = preload("res://scenes/characters/Orc.tscn")

onready var orc: KinematicBody2D = $YSort/Orc

onready var ysort = $YSort

var player_team = [
    [FRAMES_HUMAN_R, 2, SCN_HUMAN1],
    [FRAMES_HUMAN_G, 3, SCN_HUMAN2],
    [FRAMES_HUMAN_R, 2, SCN_HUMAN1],
]

onready var buttons = [
    $BattleGUI/ActionButton1,
    $BattleGUI/ActionButton2,
    $BattleGUI/ActionButton3,
]

onready var paths = [
    $Stage/Paths/Path1,
    $Stage/Paths/Path2,
    $Stage/Paths/Path3,
]

onready var player_spawns = $Stage/SpawnPlayer.get_children()
onready var enemy_spawns = $Stage/SpawnEnemy.get_children()


func _ready():
    orc.set_patrol_path($Stage/Paths/Path2.get_path())

    for i in range(len(buttons)):
        buttons[i].connect("button_clicked", self, "_on_button_clicked", [i])
        var unit = player_team[i]
        buttons[i].set_unit(unit[0], unit[1])


func _process(delta):
    pass


func _on_spawn_projectile(projectile, source, target):
    match projectile:
        Global.Projectiles.ARROW:
            _spawn_projectile(SCN_PROJECTILE, source, target)
        _:
            pass


func _spawn_projectile(scene, source, target):
    var obj = scene.instance()
    obj.position = source.position
    obj.target = target.get_hitbox_position()
    obj.power = source.power
    obj.collision_layer = 0
    obj.collision_mask = ~(1 << source.team)
    ysort.add_child(obj)


func _on_button_clicked(i: int):
    print("Button ", i, " clicked.")
    # buttons[i].disable()
    var minion = player_team[i][2].instance()
    var spawn = player_spawns[i]
    minion.position = spawn.position
    minion.team = 0
    minion.patrol_path = paths[i].get_path()
    minion.connect("spawn_projectile", self, "_on_spawn_projectile")
    ysort.add_child(minion)
