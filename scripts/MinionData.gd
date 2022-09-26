extends Resource

class_name MinionData

################################################################################
# Variables
################################################################################

export (Global.Races) var race: int = Global.Races.NONE
export (String) var name: String = "Minion"
export (Global.Roles) var role: int = Global.Roles.MELEE
export (int, 1, 10) var cost: int = 1

export (Global.HealthTiers) var health: int = Global.HealthTiers.TIER1
export (Global.PowerTiers) var power: int = Global.PowerTiers.TIER1

export (Global.MovementSpeeds) var move_speed: int = Global.MovementSpeeds.SLOWEST

export (Global.AttackSpeeds) var attack_speed: int = Global.AttackSpeeds.SLOWEST
export (Global.AttackRanges) var attack_range: int = Global.AttackRanges.MELEE
export (Global.Projectiles) var projectile: int = Global.Projectiles.NONE
export (Global.DamageTypes) var damage_type: int = Global.DamageTypes.PHYSICAL

export (Global.WeaponTypes) var weapon_type: int = Global.WeaponTypes.NORMAL
export (Global.ArmorTypes) var armor_type: int = Global.ArmorTypes.LIGHT
export (Global.MagicResistance) var magic_resistance: int = Global.MagicResistance.LIGHT

export (Global.Abilities) var ability: int = Global.Abilities.NONE


################################################################################
# Interface
################################################################################


func get_sprite_frames(team: int) -> SpriteFrames:
    return Global.load_sprite_frames(race, name, team)


func read_from_json(path: String) -> void:
    var json: JSONParseResult = JSON.parse(path)
    if json.error != OK:
        push_error(json.error_string)
    var result = json.result
    race = int(result["race"])
    name = result["name"]
    role = int(result["role"])
    cost = int(result["cost"])
    health = int(result["health"])
    power = int(result["power"])
    move_speed = int(result["move_speed"])
    attack_speed = int(result["attack_speed"])
    attack_range = int(result["attack_range"])
    projectile = int(result["projectile"])
    damage_type = int(result["damage_type"])
    armor_type = int(result["armor_type"])
    magic_resistance = int(result["magic_resistance"])
