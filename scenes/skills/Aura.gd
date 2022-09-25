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
    $Tween.interpolate_property(
        sprite,
        "modulate:a",
        sprite.modulate.a,
        0,
        2.0,
        Tween.TRANS_SINE,
        Tween.EASE_IN_OUT
    )
    $Tween.start()


################################################################################
# Event Handlers
################################################################################


func _on_Aura_body_entered(target):
    match ability:
        Global.Abilities.AURA_ALL_DAMAGE_BUFF:
            target.physical_damage_bonuses += 1
            target.magic_damage_bonuses += 1
        Global.Abilities.AURA_PHYSICAL_DAMAGE_BUFF:
            target.physical_damage_bonuses += 1
        Global.Abilities.AURA_MAGIC_DAMAGE_BUFF:
            target.magic_damage_bonuses += 1
        Global.Abilities.AURA_DEFENSES_BUFF:
            target.armor_bonuses += 1
            target.magic_resist_bonuses += 1
        Global.Abilities.AURA_ARMOR_BUFF:
            target.armor_bonuses += 1
        Global.Abilities.AURA_MAGIC_RESIST_BUFF:
            target.magic_resist_bonuses += 1
        Global.Abilities.AURA_HEALTH_REGENERATION:
            target.health_regen_effects += 1
        Global.Abilities.AURA_LIFESTEAL_MELEE:
            target.melee_lifesteal_effects += 1


func _on_Aura_body_exited(target):
    match ability:
        Global.Abilities.AURA_ALL_DAMAGE_BUFF:
            target.physical_damage_bonuses -= 1
            target.magic_damage_bonuses -= 1
        Global.Abilities.AURA_PHYSICAL_DAMAGE_BUFF:
            target.physical_damage_bonuses -= 1
        Global.Abilities.AURA_MAGIC_DAMAGE_BUFF:
            target.magic_damage_bonuses -= 1
        Global.Abilities.AURA_DEFENSES_BUFF:
            target.armor_bonuses -= 1
            target.magic_resist_bonuses -= 1
        Global.Abilities.AURA_ARMOR_BUFF:
            target.armor_bonuses -= 1
        Global.Abilities.AURA_MAGIC_RESIST_BUFF:
            target.magic_resist_bonuses -= 1
        Global.Abilities.AURA_HEALTH_REGENERATION:
            target.health_regen_effects -= 1
        Global.Abilities.AURA_LIFESTEAL_MELEE:
            target.melee_lifesteal_effects -= 1
