extends Node2D

const SCN_PROJECTILE = preload("res://scenes/objects/Projectile.tscn")

const FRAMES_HUMAN_R = preload("res://data/animation/Human.tres")
const FRAMES_HUMAN_G = preload("res://data/animation/HumanGreen.tres")

const SCN_HUMAN1 = preload("res://scenes/characters/Human.tscn")
const SCN_HUMAN2 = preload("res://scenes/characters/HumanArcher.tscn")
const SCN_ORC1 = preload("res://scenes/characters/Orc.tscn")

onready var ysort = $YSort

var player_team = [
    [FRAMES_HUMAN_R, 2, SCN_HUMAN1],
    [FRAMES_HUMAN_G, 3, SCN_HUMAN2],
    [FRAMES_HUMAN_R, 2, SCN_HUMAN1],
]

var enemy_team = [
    SCN_ORC1,
]

onready var buttons = [
    $BattleGUI/HUD/V/ActionBar/ActionButton1,
    $BattleGUI/HUD/V/ActionBar/ActionButton2,
    $BattleGUI/HUD/V/ActionBar/ActionButton3,
]

onready var paths = [
    $Stage/Paths/Path1,
    $Stage/Paths/Path2,
    $Stage/Paths/Path3,
]

onready var player_spawns = $Stage/SpawnPlayer.get_children()
onready var enemy_spawns = $Stage/SpawnEnemy.get_children()


func _ready():
    randomize()
    for i in range(len(buttons)):
        buttons[i].connect("pressed", self, "_on_button_clicked", [i])
        var unit = player_team[i]
        buttons[i].set_unit(unit[0], unit[1])



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


func _spawn_minion(scn: PackedScene, team: int, spawn: Node2D, path: NodePath):
    var minion = scn.instance()
    minion.position = spawn.position
    minion.team = team
    minion.patrol_path = path
    minion.connect("spawn_projectile", self, "_on_spawn_projectile")
    ysort.add_child(minion)


func _on_button_clicked(i: int):
    print("Button ", i, " clicked.")
    # buttons[i].disable()
    var scene = player_team[i][2]
    var team = 0
    var spawn = player_spawns[i]
    var path = paths[i].get_path()
    _spawn_minion(scene, team, spawn, path)


func _on_EnemyTimer_timeout():
    var r = randi()
    var scene = enemy_team[r % len(enemy_team)]
    var team = 1
    var spawn = enemy_spawns[r % len(enemy_spawns)]
    var path = paths[r % len(paths)].get_path()
    _spawn_minion(scene, team, spawn, path)
