extends Resource

class_name MinionData

################################################################################
# Variables
################################################################################

export (String) var name: String = "Minion"
export (SpriteFrames) var frames

export (Global.Roles) var role: int = Global.Roles.MELEE
export (int, 1, 10) var cost: int = 1
export (int, 1, 1000) var health: int = 40
export (int, 1, 100) var power: int = 5

export (float, 1.0, 100.0) var move_speed: float = 8.0  # pixels/sec

export (float, 0.1, 5.0) var attack_speed: float = 1.0  # seconds
export (Global.AttackRanges) var attack_range: int = Global.AttackRanges.MELEE
export (Global.Projectiles) var projectile: int = Global.Projectiles.NONE
export (Global.DamageTypes) var damage_type: int = Global.DamageTypes.PHYSICAL
export (Global.ArmorTypes) var armor_type: int = Global.ArmorTypes.LIGHT
export (Global.MagicResistance) var magic_resistance: int = Global.MagicResistance.LIGHT
