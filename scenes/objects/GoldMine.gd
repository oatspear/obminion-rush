extends "res://scenes/objects/Destructible.gd"

################################################################################
# Constants
################################################################################

const TEXTURE_NEUTRAL = preload("res://assets/objects/Mine/Neutral.png")
const TEXTURE_BLUE = preload("res://assets/objects/Mine/Blue.png")
const TEXTURE_RED = preload("res://assets/objects/Mine/Red.png")
const TEXTURE_PURPLE = preload("res://assets/objects/Mine/Purple.png")
const TEXTURE_YELLOW = preload("res://assets/objects/Mine/Yellow.png")
const TEXTURE_GREEN = preload("res://assets/objects/Mine/Green.png")
const TEXTURE_CYAN = preload("res://assets/objects/Mine/Cyan.png")

const COLOUR_TEXTURES = {
    Global.TeamColours.NONE: TEXTURE_NEUTRAL,
    Global.TeamColours.BLUE: TEXTURE_BLUE,
    Global.TeamColours.RED: TEXTURE_RED,
    Global.TeamColours.GREEN: TEXTURE_GREEN,
    Global.TeamColours.YELLOW: TEXTURE_YELLOW,
}

################################################################################
# Interface
################################################################################

func set_owner_team(new_team: int, colour: int):
    team = new_team
    sprite.texture = COLOUR_TEXTURES[colour]
    # collision_layer = Global.get_collision_layer(team)
    health = max_health
    health_bar.set_value(health, max_health)
