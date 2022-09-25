extends Area2D

################################################################################
# Variables
################################################################################

export (int) var team_colour: int = 0
export (Global.Abilities) var ability: int = Global.Abilities.NONE

onready var sprite = $Sprite

################################################################################
# Interface
################################################################################


func set_team(team: int):
    collision_mask = Global.get_collision_layer(team)


func _ready():
    $CollisionShape2D.shape.radius = Global.AGGRO_RANGE
    sprite.modulate = Global.get_team_colour(team_colour)


################################################################################
# Event Handlers
################################################################################


func _on_Aura_body_entered(target):
    match ability:
        Global.Abilities.AURA_FRIEND_ALL_DAMAGE_BUFF:
            target.physical_damage_bonuses += 1
            target.magic_damage_bonuses += 1
        Global.Abilities.AURA_FRIEND_PHYSICAL_DAMAGE_BUFF:
            target.physical_damage_bonuses += 1
        Global.Abilities.AURA_FRIEND_MAGIC_DAMAGE_BUFF:
            target.magic_damage_bonuses += 1


func _on_Aura_body_exited(target):
    match ability:
        Global.Abilities.AURA_FRIEND_ALL_DAMAGE_BUFF:
            target.physical_damage_bonuses -= 1
            target.magic_damage_bonuses -= 1
        Global.Abilities.AURA_FRIEND_PHYSICAL_DAMAGE_BUFF:
            target.physical_damage_bonuses -= 1
        Global.Abilities.AURA_FRIEND_MAGIC_DAMAGE_BUFF:
            target.magic_damage_bonuses -= 1
