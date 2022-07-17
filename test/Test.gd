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
    $BattleGUI/Margin/V/ActionBar/ActionButton1,
    $BattleGUI/Margin/V/ActionBar/ActionButton2,
    $BattleGUI/Margin/V/ActionBar/ActionButton3,
]

onready var paths = [
    $Stage/Paths/Path1,
    $Stage/Paths/Path2,
    $Stage/Paths/Path3,
]

onready var player_spawns = $Stage/SpawnPlayer.get_children()
onready var enemy_spawns = $Stage/SpawnEnemy.get_children()


var player_coins = 12
onready var gold_label = $BattleGUI/Margin/V/StatusBar/Gold

var next_player_unit
onready var next_unit_icon = $BattleGUI/Margin/V/StatusBar/Next/Icon/Sprite

onready var wingraphic: CanvasLayer = $WinGraphic
onready var tween: Tween = $Tween


func _ready():
    randomize()
    next_player_unit = _random_unit(player_team)
    for i in range(len(buttons)):
        buttons[i].connect("pressed", self, "_on_button_clicked", [i])
        buttons[i].set_unit(next_player_unit[0], next_player_unit[1])
        buttons[i].unit_type = next_player_unit[2]
        next_player_unit = _random_unit(player_team)
    next_unit_icon.frames = next_player_unit[0]
    gold_label.set_value(player_coins)


func _random_unit(team: Array):
    return team[randi() % len(team)]


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
    var scene = buttons[i].unit_type
    var team = 0
    var spawn = player_spawns[i]
    var path = paths[i].get_path()
    var cost = buttons[i].cost
    if cost <= player_coins:
        player_coins -= cost
        gold_label.set_value(player_coins)
        _spawn_minion(scene, team, spawn, path)
        # regenerate next unit
        buttons[i].set_unit(next_player_unit[0], next_player_unit[1])
        buttons[i].unit_type = next_player_unit[2]
        next_player_unit = _random_unit(player_team)
        next_unit_icon.frames = next_player_unit[0]
    for button in buttons:
        if button.cost > player_coins:
            button.disable()


func _on_EnemyTimer_timeout():
    var r = randi()
    var scene = enemy_team[r % len(enemy_team)]
    var team = 1
    var spawn = enemy_spawns[r % len(enemy_spawns)]
    var path = paths[r % len(paths)].get_path()
    _spawn_minion(scene, team, spawn, path)


func _on_Win_body_entered(body):
    if body.team == 0:
        tween.interpolate_property(wingraphic, "offset",
            wingraphic.offset, Vector2.ZERO, 1.0,
            Tween.TRANS_SINE,
            Tween.EASE_OUT)
        tween.start()
        $EnemyTimer.stop()
