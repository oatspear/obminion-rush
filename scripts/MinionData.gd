extends Resource

class_name MinionData

################################################################################
# Variables
################################################################################

export (Global.Races) var race: int = Global.Races.NONE
export (String) var name: String = "Minion"

export (Global.Roles) var role: int = Global.Roles.MELEE
export (int, 1, 10) var cost: int = 1
export (int, 1, 1000) var health: int = 40
export (int, 1, 100) var power: int = 5

export (Global.MovementSpeeds) var move_speed: int = Global.MovementSpeeds.SLOWEST

export (Global.AttackSpeeds) var attack_speed: int = Global.AttackSpeeds.SLOWEST
export (Global.AttackRanges) var attack_range: int = Global.AttackRanges.MELEE
export (Global.Projectiles) var projectile: int = Global.Projectiles.NONE
export (Global.DamageTypes) var damage_type: int = Global.DamageTypes.PHYSICAL
export (Global.ArmorTypes) var armor_type: int = Global.ArmorTypes.LIGHT
export (Global.MagicResistance) var magic_resistance: int = Global.MagicResistance.LIGHT


################################################################################
# Interface
################################################################################


func get_sprite_frames(team: int) -> SpriteFrames:
    return Global.load_sprite_frames(race, name, team)
