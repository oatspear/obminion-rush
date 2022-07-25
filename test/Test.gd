extends Node2D

const SCN_ARROW = preload("res://scenes/objects/Arrow.tscn")
const SCN_FIREBALL = preload("res://scenes/objects/Fireball.tscn")

const FRAMES_PLAYER_SOLDIER = preload("res://data/animation/HumanSoldierBlue.tres")
const FRAMES_PLAYER_ARCHER = preload("res://data/animation/HumanArcherGreen.tres")
const FRAMES_PLAYER_MAGE = preload("res://data/animation/HumanMageCyan.tres")

const SCN_HUMAN1 = preload("res://scenes/characters/HumanSoldierBlue.tscn")
const SCN_HUMAN2 = preload("res://scenes/characters/HumanArcherGreen.tscn")
const SCN_HUMAN3 = preload("res://scenes/characters/HumanMageCyan.tscn")

const SCN_ENEMY1 = preload("res://scenes/characters/HumanWarriorRed.tscn")
const SCN_ENEMY2 = preload("res://scenes/characters/HumanArcherPurple.tscn")
const SCN_ENEMY3 = preload("res://scenes/characters/HumanMageRed.tscn")

const SCN_HERO1 = preload("res://scenes/characters/HeroSoldierBlue.tscn")
const SCN_HERO2 = preload("res://scenes/characters/HeroSoldierRed.tscn")

onready var stage = $Stage

var player_team = [
    [FRAMES_PLAYER_SOLDIER, 2, SCN_HUMAN1],
    [FRAMES_PLAYER_ARCHER, 3, SCN_HUMAN2],
    [FRAMES_PLAYER_MAGE, 2, SCN_HUMAN3],
]

var enemy_team = [
    SCN_ENEMY1,
    SCN_ENEMY2,
    SCN_ENEMY3,
]

onready var buttons = [
    $BattleGUI/Margin/V/ActionBar/ActionButton1,
    $BattleGUI/Margin/V/ActionBar/ActionButton2,
    $BattleGUI/Margin/V/ActionBar/ActionButton3,
]


var player_coins = 12
onready var gold_label = $BattleGUI/Margin/V/StatusBar/Gold

var next_player_unit
onready var next_unit_icon = $BattleGUI/Margin/V/StatusBar/Next/Icon/Sprite

onready var wingraphic: CanvasLayer = $WinGraphic
onready var winlabel: Label = $WinGraphic/CenterContainer/Label
onready var tween: Tween = $Tween


func _ready():
    randomize()
    next_player_unit = _random_unit(player_team)
    for i in range(len(buttons)):
        buttons[i].connect("pressed", self, "_on_button_clicked", [i])
        buttons[i].connect("reset_cooldown", self, "_on_button_reset_cooldown", [i])
        buttons[i].set_unit(next_player_unit[0], next_player_unit[1])
        buttons[i].unit_type = next_player_unit[2]
        next_player_unit = _random_unit(player_team)
    next_unit_icon.frames = next_player_unit[0]
    gold_label.set_value(player_coins)
    _spawn_heroes()


func _random_unit(team: Array):
    return team[randi() % len(team)]


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
    stage.spawn_object(obj)


func _spawn_minion(scn: PackedScene, team: int, spawn: int):
    var minion = scn.instance()
    minion.team = team
    minion.connect("spawn_projectile", self, "_on_spawn_projectile")
    stage.spawn_minion(minion, spawn)


func _spawn_heroes():
    # blue
    var minion = SCN_HERO1.instance()
    minion.team = Global.Teams.BLUE
    minion.connect("spawn_projectile", self, "_on_spawn_projectile")
    stage.spawn_hero(minion)
    # red
    minion = SCN_HERO2.instance()
    minion.team = Global.Teams.RED
    minion.connect("spawn_projectile", self, "_on_spawn_projectile")
    stage.spawn_hero(minion)


func _on_button_clicked(i: int):
    var scene = buttons[i].unit_type
    var team = Global.Teams.BLUE
    var spawn = 0
    var cost = buttons[i].cost
    if cost <= player_coins:
        player_coins -= cost
        gold_label.set_value(player_coins)
        _spawn_minion(scene, team, spawn)
        # regenerate next unit
        buttons[i].set_unit(next_player_unit[0], next_player_unit[1])
        buttons[i].unit_type = next_player_unit[2]
        buttons[i].disable()
        buttons[i].start_cooldown()
        next_player_unit = _random_unit(player_team)
        next_unit_icon.frames = next_player_unit[0]
    for button in buttons:
        if button.cost > player_coins:
            button.disable()


func _on_button_reset_cooldown(i: int):
    if buttons[i].cost <= player_coins:
        buttons[i].enable()


func _on_EnemyTimer_timeout():
    var r = randi()
    var scene = enemy_team[r % len(enemy_team)]
    var team = Global.Teams.RED
    var spawn = r % stage.num_spawn_points(Global.Teams.RED)
    _spawn_minion(scene, team, spawn)

    player_coins += 1
    gold_label.set_value(player_coins)
    for button in buttons:
        if button.cost <= player_coins and not button.is_on_cooldown():
            button.enable()


func _on_Stage_objective_captured(team: int):
    if team == Global.Teams.RED:  # player (BLUE) captured enemy (RED)
        winlabel.text = "Victory"
    else:
        winlabel.text = "Defeat"
    tween.interpolate_property(wingraphic, "offset",
        wingraphic.offset, Vector2.ZERO, 1.0,
        Tween.TRANS_SINE,
        Tween.EASE_OUT)
    tween.start()
    $EnemyTimer.stop()
