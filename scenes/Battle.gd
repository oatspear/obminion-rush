extends Node2D

################################################################################
# Constants
################################################################################

const STAGE_SCENE_PATH = "res://scenes/stages/%s.tscn"
const STAGE_NODE_NAME = "Stage"

const SCN_ARROW = preload("res://scenes/objects/Arrow.tscn")
const SCN_FIREBALL = preload("res://scenes/objects/Fireball.tscn")
const SCN_MINION = preload("res://scenes/characters/Minion.tscn")
const SCN_HERO = preload("res://scenes/characters/Hero.tscn")
const SCN_AOE_DAMAGE_PHYSICAL = preload("res://scenes/skills/aoe/damage/Physical.tscn")
const SCN_AOE_DAMAGE_FIRE = preload("res://scenes/skills/aoe/damage/Fire.tscn")
const SCN_SP_ATTACK_HELPER = preload("res://scenes/skills/SpecialAttackHelper.tscn")

const BUTTON_COOLDOWN = 1.5

const SCORE_TIME_FAST = 60.0  # first minute
const SCORE_TIME_EARLY = 60.0 * 2  # first two minutes
const SCORE_TIME_LATE = 60.0 * 5  # five minutes onward

const INCOME_RATE = 2.5  # seconds for one coin
const GOLD_MINE_INCOME_RATE_BONUS = 0.85

################################################################################
# Variables
################################################################################

var neutral_player: BattlePlayer = BattlePlayer.new()
var the_player: BattlePlayer = BattlePlayer.new()
var the_enemy: BattlePlayer = BattlePlayer.new()

var players: Array = [neutral_player, the_player, the_enemy]

onready var stage = get_node(STAGE_NODE_NAME)

onready var gui = $BattleGUI

onready var overlay_layer: CanvasLayer = $OverlayText
onready var overlay_label: Label = $OverlayText/CenterContainer/Label
onready var tween: Tween = $Tween

var _temp_unit_type: int = -1
var _playing: bool = true

var _playtime: float = 0

################################################################################
# Initialization
################################################################################

# to be called during initialization, before `_ready()`
func set_stage(scene_name: String):
    var scene = load(STAGE_SCENE_PATH % scene_name)
    var new_stage = scene.instance()
    new_stage.name = STAGE_NODE_NAME
    new_stage.connect("objective_captured", self, "_on_Stage_objective_captured")
    new_stage.connect("resource_changed_owner", self, "_on_Stage_resource_changed_owner")
    add_child(new_stage)
    move_child(new_stage, 0)


func _ready():
    for i in range(len(players)):
        players[i].team = i
        players[i].income_rate = _calc_income_rate(players[i])
        players[i].income_timer = players[i].income_rate
    _init_the_player()
    # _init_player(the_enemy)


func _init_the_player():
    var unit = the_player.pick_next_minion()
    for i in range(gui.get_num_action_buttons()):
        var frames = unit.get_sprite_frames(the_player.team_colour)
        gui.set_action_button(i, the_player.next_minion, frames, unit.cost)
        unit = the_player.pick_next_minion()
    gui.set_next_role(unit.role)
    gui.set_player_gold(the_player.coins)
    gui.ensure_area_selectors(stage.num_spawn_points(the_player.team))
    _spawn_heroes()


################################################################################
# Game Logic
################################################################################

func _process(delta):
    if not _playing:
        return
    _playtime += delta
    var refresh = false
    the_player.income_timer -= delta
    while the_player.income_timer <= 0:
        the_player.coins += 1
        the_player.income_timer += the_player.income_rate
        refresh = true
    the_enemy.income_timer -= delta
    while the_enemy.income_timer <= 0:
        the_enemy.coins += 1
        the_enemy.income_timer += the_enemy.income_rate
    if refresh:
        gui.set_player_gold(the_player.coins)


func _on_spawn_projectile(projectile, source, target):
    match projectile:
        Global.Projectiles.ARROW:
            _spawn_projectile(SCN_ARROW, source, target)
        Global.Projectiles.FIRE:
            _spawn_projectile(SCN_FIREBALL, source, target)
        _:
            pass


func _on_spawn_area_effect(ability: int, caster, point: Vector2):
    match ability:
        Global.Abilities.AOE_DAMAGE_PHYSICAL:
            _spawn_area_effect(SCN_AOE_DAMAGE_PHYSICAL, caster, point)
        Global.Abilities.AOE_DAMAGE_FIRE:
            _spawn_area_effect(SCN_AOE_DAMAGE_FIRE, caster, point)


func _spawn_projectile(scene, source, target):
    var obj = scene.instance()
    obj.team = source.team
    obj.source = weakref(source)
    obj.position.x = source.position.x
    obj.position.y = source.position.y
    obj.target = target.position
    obj.power = source._calc_damage_output(source.damage_type)
    obj.weapon_type = source.weapon_type
    stage.spawn_object(obj)


func _spawn_area_effect(scene, caster, point):
    var obj = scene.instance()
    obj.team = caster.team
    obj.source = weakref(caster)
    obj.position.x = point.x
    obj.position.y = point.y
    obj.power = caster._calc_damage_output(obj.damage_type)
    stage.spawn_area_effect(obj)


func _spawn_minion(base_data: MinionData, team: int, spawn: int):
    var minion = SCN_MINION.instance()
    minion.team = team
    minion.team_colour = players[team].team_colour
    minion.base_data = base_data
    minion.connect("spawn_projectile", self, "_on_spawn_projectile")
    minion.connect("spawn_area_effect", self, "_on_spawn_area_effect")
    _handle_ability(minion, base_data.ability)
    stage.spawn_minion(minion, spawn)


func _spawn_heroes():
    # blue
    var minion = SCN_HERO.instance()
    minion.team = the_player.team
    minion.team_colour = the_player.team_colour
    minion.base_data = the_player.hero_data
    minion.connect("spawn_projectile", self, "_on_spawn_projectile")
    minion.connect("spawn_area_effect", self, "_on_spawn_area_effect")
    _handle_ability(minion, the_player.hero_data.ability)
    stage.spawn_hero(minion)
    the_player.hero_ref = weakref(minion)
    # red
    minion = SCN_HERO.instance()
    minion.team = the_enemy.team
    minion.team_colour = the_enemy.team_colour
    minion.base_data = the_enemy.hero_data
    minion.connect("spawn_projectile", self, "_on_spawn_projectile")
    minion.connect("spawn_area_effect", self, "_on_spawn_area_effect")
    _handle_ability(minion, the_enemy.hero_data.ability)
    minion.connect("took_damage", self, "_on_enemy_took_damage")
    stage.spawn_hero(minion)
    the_enemy.hero_ref = weakref(minion)


func _calc_income_rate(player: BattlePlayer) -> float:
    var rate = INCOME_RATE
    for i in range(player.gold_mines):
        rate *= GOLD_MINE_INCOME_RATE_BONUS
    return rate


################################################################################
# Event Handlers
################################################################################

func _on_EnemyTimer_timeout():
    var unit = the_enemy.pick_next_minion()
    if unit.cost <= the_enemy.coins:
        the_enemy.coins -= unit.cost
        var team = the_enemy.team
        var spawn = randi() % stage.num_spawn_points(the_enemy.team)
        _spawn_minion(unit, team, spawn)


func _on_Stage_objective_captured(team: int):
    if not _playing:
        return
    if team == the_enemy.team:  # player captured enemy
        overlay_label.text = "Victory"
    else:
        overlay_label.text = "Defeat"
    var _np = tween.interpolate_property(overlay_layer, "offset",
        overlay_layer.offset, Vector2.ZERO, 1.0,
        Tween.TRANS_SINE,
        Tween.EASE_OUT)
    _np = tween.start()
    _playing = false
    gui.hide_all_inputs()


func _on_Stage_resource_changed_owner(node, previous: int, current: int):
    assert("GoldMine" in node.name)
    match previous:
        the_player.team:
            assert(the_player.gold_mines > 0)
            the_player.gold_mines -= 1
        the_enemy.team:
            assert(the_enemy.gold_mines > 0)
            the_enemy.gold_mines -= 1
    match current:
        the_player.team:
            the_player.gold_mines += 1
            the_player.set_income_rate(_calc_income_rate(the_player))
        the_enemy.team:
            the_enemy.gold_mines += 1
            the_enemy.set_income_rate(_calc_income_rate(the_enemy))


func _on_BattleGUI_spawn_minion_requested(_i, unit_type):
    # print("spawn unit requested: ", unit_type)
    _temp_unit_type = unit_type
    var spawns = stage.get_spawn_points(the_player.team)
    for i in range(len(spawns)):
        gui.set_area_selector(i, spawns[i])
    gui.select_target_area()


func _on_BattleGUI_area_selected(i: int, _x: float, _y: float):
    # print("spawn area selected: ", i)
    var unit = the_player.minion_data[_temp_unit_type]
    var cost = unit.cost
    if cost <= the_player.coins:
        _spawn_minion(unit, the_player.team, i)
        # regenerate next unit
        unit = the_player.get_next_minion()
        var frames = unit.get_sprite_frames(the_player.team_colour)
        gui.set_action_button(
            gui.last_action_button,
            the_player.next_minion,
            frames,
            unit.cost,
            BUTTON_COOLDOWN
        )
        # update gold last to take into account new button data
        the_player.coins -= cost
        gui.set_player_gold(the_player.coins)
        # update next unit hint
        unit = the_player.pick_next_minion()
        gui.set_next_role(unit.role)


func _on_enemy_took_damage(amount: int, _typed: int):
    var percent = 0
    var hero = the_player.hero_ref.get_ref()
    if hero:
        percent = round((hero.health * 100.0) / hero.max_health)
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
    the_player.score += score
    gui.set_player_score(the_player.score)


func _handle_ability(minion, ability: int):
    if (
        ability > Global.Abilities.SPECIAL_ATTACKS_START
        and ability < Global.Abilities.SPECIAL_ATTACKS_END
    ):
        var helper = SCN_SP_ATTACK_HELPER.instance()
        helper.special_attack = ability
        minion.add_child(helper)
