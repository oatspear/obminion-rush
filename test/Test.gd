extends Node2D

################################################################################
# Constants
################################################################################

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

const BUTTON_COOLDOWN = 1.5

################################################################################
# Variables
################################################################################

onready var stage = $Stage

var player_team = [
    [FRAMES_PLAYER_SOLDIER, 2, SCN_HUMAN1, Global.Roles.MELEE],
    [FRAMES_PLAYER_ARCHER, 3, SCN_HUMAN2, Global.Roles.RANGED],
    [FRAMES_PLAYER_MAGE, 2, SCN_HUMAN3, Global.Roles.CASTER],
]

var player_roster = []

var enemy_team = [
    SCN_ENEMY1,
    SCN_ENEMY2,
    SCN_ENEMY3,
]

onready var gui = $BattleGUI

var player_coins = 12
var next_player_unit: int = 0

onready var wingraphic: CanvasLayer = $WinGraphic
onready var winlabel: Label = $WinGraphic/CenterContainer/Label
onready var tween: Tween = $Tween


################################################################################
# Initialization
################################################################################

func _ready():
    randomize()
    next_player_unit = _randi(player_team)
    var unit = player_team[next_player_unit]
    for i in range(gui.get_num_action_buttons()):
        #buttons[i].connect("pressed", self, "_on_button_clicked", [i])
        #buttons[i].connect("reset_cooldown", self, "_on_button_reset_cooldown", [i])
        gui.set_action_button(i, next_player_unit, unit[0], unit[1])
        next_player_unit = _randi(player_team)
        unit = player_team[next_player_unit]
    gui.set_next_role(unit[3])
    gui.set_player_gold(player_coins)
    _spawn_heroes()


################################################################################
# Game Logic
################################################################################

func _randi(collection) -> int:
    return randi() % len(collection)


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


################################################################################
# Event Handlers
################################################################################

func _on_EnemyTimer_timeout():
    var r = randi()
    var scene = enemy_team[r % len(enemy_team)]
    var team = Global.Teams.RED
    var spawn = r % stage.num_spawn_points(Global.Teams.RED)
    _spawn_minion(scene, team, spawn)

    player_coins += 2
    gui.set_player_gold(player_coins)


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


func _on_BattleGUI_spawn_minion_requested(i, unit_type):
    var unit = player_team[unit_type]
    var scene = unit[2]
    var team = Global.Teams.BLUE
    var spawn = 0
    var cost = unit[1]
    if cost <= player_coins:
        _spawn_minion(scene, team, spawn)
        # regenerate next unit
        unit = player_team[next_player_unit]
        gui.set_action_button(i, next_player_unit, unit[0], unit[1], BUTTON_COOLDOWN)
        # update gold last to take into account new button data
        player_coins -= cost
        gui.set_player_gold(player_coins)
        # update next unit hint
        next_player_unit = _randi(player_team)
        unit = player_team[next_player_unit]
        gui.set_next_role(unit[3])


func _on_BattleGUI_area_selected(i: int, x: float, y: float):
    pass # Replace with function body.
