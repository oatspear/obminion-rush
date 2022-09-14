extends Node2D

################################################################################
# Constants
################################################################################

const SCN_ARROW = preload("res://scenes/objects/Arrow.tscn")
const SCN_FIREBALL = preload("res://scenes/objects/Fireball.tscn")
const SCN_MINION = preload("res://scenes/characters/Minion.tscn")
const SCN_HERO = preload("res://scenes/characters/Hero.tscn")

const DATA_BLUE_SOLDIER = preload("res://data/minions/Human/Tier2/Tank.tres")
const DATA_BLUE_MAGE = preload("res://data/minions/Human/Tier3/Mage.tres")
const DATA_BLUE_ARCHER = preload("res://data/minions/Human/Tier2/Archer.tres")

const DATA_RED_WARRIOR = preload("res://data/minions/Human/Tier2/Warrior.tres")
const DATA_RED_MAGE = preload("res://data/minions/Human/Tier2/Mage.tres")
const DATA_RED_ARCHER = preload("res://data/minions/Human/Tier3/Archer.tres")

const DATA_BLUE_HERO = preload("res://data/minions/Human/Hero/Hero1.tres")
const DATA_RED_HERO = preload("res://data/minions/Human/Hero/Hero2.tres")

const BUTTON_COOLDOWN = 1.5

const SCORE_TIME_FAST = 60.0  # first minute
const SCORE_TIME_EARLY = 60.0 * 2  # first two minutes
const SCORE_TIME_LATE = 60.0 * 5  # five minutes onward

const INCOME_RATE = 2.5  # seconds for one coin

const PLAYER_TEAM = 1
const ENEMY_TEAM = 2

################################################################################
# Variables
################################################################################

onready var stage = $Stage

var team_colours = [
    Global.TeamColours.NONE,
    Global.TeamColours.BLUE,
    Global.TeamColours.RED
]

var player_team = [
    DATA_BLUE_SOLDIER,
    DATA_BLUE_ARCHER,
    DATA_BLUE_MAGE,
]

var player_roster = []

var enemy_team = [
    DATA_RED_WARRIOR,
    DATA_RED_ARCHER,
    DATA_RED_MAGE,
]

var enemy_coins = 0

onready var gui = $BattleGUI

var player_coins = 4
var player_score = 0
var next_player_unit: int = 0

onready var wingraphic: CanvasLayer = $WinGraphic
onready var winlabel: Label = $WinGraphic/CenterContainer/Label
onready var tween: Tween = $Tween

var _temp_unit_type: int = -1
var _playing: bool = true

var _player_hero: WeakRef
var _enemy_hero: WeakRef
var _playtime: float = 0

onready var _income_timer: float = INCOME_RATE

################################################################################
# Initialization
################################################################################

func _ready():
    randomize()
    next_player_unit = _randi(player_team)
    var unit = player_team[next_player_unit]
    for i in range(gui.get_num_action_buttons()):
        var frames = unit.get_sprite_frames(team_colours[PLAYER_TEAM])
        gui.set_action_button(i, next_player_unit, frames, unit.cost)
        next_player_unit = _randi(player_team)
        unit = player_team[next_player_unit]
    gui.set_next_role(unit.role)
    gui.set_player_gold(player_coins)
    gui.ensure_area_selectors(stage.num_spawn_points(PLAYER_TEAM))
    _spawn_heroes()


################################################################################
# Game Logic
################################################################################

func _process(delta):
    _playtime += delta
    var refresh = false
    _income_timer -= delta
    while _income_timer <= 0:
        player_coins += 1
        _income_timer += INCOME_RATE
        refresh = true
    if refresh:
        gui.set_player_gold(player_coins)


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


func _spawn_minion(base_data: MinionData, team: int, spawn: int):
    var minion = SCN_MINION.instance()
    minion.team = team
    minion.team_colour = team_colours[team]
    minion.base_data = base_data
    minion.connect("spawn_projectile", self, "_on_spawn_projectile")
    stage.spawn_minion(minion, spawn)


func _spawn_heroes():
    # blue
    var minion = SCN_HERO.instance()
    minion.team = PLAYER_TEAM
    minion.team_colour = team_colours[PLAYER_TEAM]
    minion.base_data = DATA_BLUE_HERO
    minion.connect("spawn_projectile", self, "_on_spawn_projectile")
    stage.spawn_hero(minion)
    _player_hero = weakref(minion)
    # red
    minion = SCN_HERO.instance()
    minion.team = ENEMY_TEAM
    minion.team_colour = team_colours[ENEMY_TEAM]
    minion.base_data = DATA_RED_HERO
    minion.connect("spawn_projectile", self, "_on_spawn_projectile")
    minion.connect("took_damage", self, "_on_enemy_took_damage")
    stage.spawn_hero(minion)
    _enemy_hero = weakref(minion)


################################################################################
# Event Handlers
################################################################################

func _on_EnemyTimer_timeout():
    enemy_coins += 1
    var r = randi()
    var unit = enemy_team[r % len(enemy_team)]
    if unit.cost <= enemy_coins:
        enemy_coins -= unit.cost
        var team = ENEMY_TEAM
        var spawn = r % stage.num_spawn_points(ENEMY_TEAM)
        _spawn_minion(unit, team, spawn)


func _on_Stage_objective_captured(team: int):
    if not _playing:
        return
    if team == ENEMY_TEAM:  # player captured enemy
        winlabel.text = "Victory"
    else:
        winlabel.text = "Defeat"
    var _np = tween.interpolate_property(wingraphic, "offset",
        wingraphic.offset, Vector2.ZERO, 1.0,
        Tween.TRANS_SINE,
        Tween.EASE_OUT)
    _np = tween.start()
    $EnemyTimer.stop()
    _playing = false


func _on_BattleGUI_spawn_minion_requested(_i, unit_type):
    # print("spawn unit requested: ", unit_type)
    _temp_unit_type = unit_type
    var spawns = stage.get_spawn_points(PLAYER_TEAM)
    for i in range(len(spawns)):
        gui.set_area_selector(i, spawns[i])
    gui.select_target_area()


func _on_BattleGUI_area_selected(i: int, _x: float, _y: float):
    # print("spawn area selected: ", i)
    var unit = player_team[_temp_unit_type]
    var team = PLAYER_TEAM
    var cost = unit.cost
    if cost <= player_coins:
        _spawn_minion(unit, team, i)
        # regenerate next unit
        unit = player_team[next_player_unit]
        var frames = unit.get_sprite_frames(team_colours[team])
        gui.set_action_button(
            gui.last_action_button,
            next_player_unit,
            frames,
            unit.cost,
            BUTTON_COOLDOWN
        )
        # update gold last to take into account new button data
        player_coins -= cost
        gui.set_player_gold(player_coins)
        # update next unit hint
        next_player_unit = _randi(player_team)
        unit = player_team[next_player_unit]
        gui.set_next_role(unit.role)


func _on_enemy_took_damage(amount: int, _typed: int):
    var percent = 0
    var h = _player_hero.get_ref()
    if h:
        percent = round((h.health * 100.0) / h.max_health)
    var score = 0
    if percent < 25:
        score = amount
    elif percent < 75:
        score = 2 * amount
    elif percent == 100:
        score = 5 * amount
    else:
        score = 3 * amount
    if _playtime < SCORE_TIME_FAST:
        score *= 2
    elif _playtime < SCORE_TIME_EARLY:
        score = int(score * 1.5)
    elif _playtime > SCORE_TIME_LATE:
        score = int(score * 0.75)
    player_score += score
    gui.set_player_score(player_score)
