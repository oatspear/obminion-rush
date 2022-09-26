extends Node2D

################################################################################
# Constants
################################################################################

const SCN_BATTLE = preload("res://scenes/Battle.tscn")

const DATA_BLUE_SOLDIER = preload("res://data/minions/Human/Tier2/Tank.tres")
const DATA_BLUE_MAGE = preload("res://data/minions/Human/Tier3/Mage.tres")
const DATA_BLUE_ARCHER = preload("res://data/minions/Human/Tier2/Archer.tres")

const DATA_RED_WARRIOR = preload("res://data/minions/Human/Tier2/Warrior.tres")
const DATA_RED_MAGE = preload("res://data/minions/Human/Tier2/Mage.tres")
const DATA_RED_ARCHER = preload("res://data/minions/Human/Tier3/Archer.tres")

const DATA_BLUE_HERO = preload("res://data/minions/Human/Hero/Hero1.tres")
const DATA_RED_HERO = preload("res://data/minions/Human/Hero/Hero2.tres")

################################################################################
# Variables
################################################################################

var current_battle

################################################################################
# Initialization
################################################################################

func _ready():
    randomize()
    _init_battle()


func _init_battle():
    current_battle = SCN_BATTLE.instance()
    current_battle.set_stage("CustomStage")
    _init_battle_player(current_battle.the_player)
    _init_battle_enemy(current_battle.the_enemy)
    add_child(current_battle)


func _init_battle_player(the_player: BattlePlayer):
    # the_player.team = 1
    the_player.team_colour = Global.TeamColours.BLUE
    the_player.hero_data = DATA_BLUE_HERO
    the_player.minion_data = [
        DATA_BLUE_SOLDIER,
        DATA_BLUE_ARCHER,
        DATA_BLUE_MAGE,
    ]
    the_player.coins = 2
    the_player.score = 0


func _init_battle_enemy(the_enemy: BattlePlayer):
    # the_enemy.team = 2
    the_enemy.team_colour = Global.TeamColours.RED
    the_enemy.hero_data = DATA_RED_HERO
    the_enemy.minion_data = [
        DATA_RED_WARRIOR,
        DATA_RED_ARCHER,
        DATA_RED_MAGE,
    ]
    the_enemy.coins = 2
    the_enemy.score = 0


################################################################################
# Game Logic
################################################################################


################################################################################
# Event Handlers
################################################################################
