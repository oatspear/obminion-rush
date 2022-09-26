extends KinematicBody2D

################################################################################
# Constants
################################################################################

const SCN_AURA = preload("res://scenes/skills/Aura.tscn")

const EPSILON = 1.0

enum FSM { IDLE, WALK, ATTACK, COOLDOWN, PURSUIT, DYING }


################################################################################
# Signals
################################################################################

signal spawn_projectile(projectile, source, target)
signal took_damage(amount)
signal healed_damage(amount)
signal died()


################################################################################
# Attributes
################################################################################

export (Resource) var base_data: Resource

export (int) var team: int = 0
export (Global.TeamColours) var team_colour: int = Global.TeamColours.NONE
export (int) var max_health: int = 20
export (int) var power: int = 2
export (float) var attack_range: float = 1.0
export (float) var attack_speed: float = 1.0  # sec
export (Global.Projectiles) var projectile: int = Global.Projectiles.NONE
export (bool) var follows_lane: bool = true
export (int, 1, 5) var cost: int = Global.MIN_UNIT_COST
export (Global.WeaponTypes) var weapon_type: int = Global.WeaponTypes.NORMAL
export (Global.DamageTypes) var damage_type: int = Global.DamageTypes.PHYSICAL
export (Global.ArmorTypes) var armor_type: int = Global.ArmorTypes.LIGHT
export (Global.MagicResistance) var magic_resistance: int = Global.MagicResistance.LIGHT

export (float) var move_speed = 30.0  # pixels / sec
var move_waypoint = null
var attack_waypoint = null

var state: int = FSM.IDLE
var under_command: bool = false

var health: int = max_health
var attack_target: WeakRef = null

var physical_damage_bonuses: int = 0
var magic_damage_bonuses: int = 0
var armor_bonuses: int = 0
var magic_resist_bonuses: int = 0
var health_regen_effects: int = 0
var melee_lifesteal_effects: int = 0
var attack_speed_bonuses: int = 0
var move_speed_bonuses: int = 0

var dodge_chance: float = 0.0

var timer: float = 0.0
var tick_timer: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var leash: Vector2 = Vector2.ZERO

onready var sprite: AnimatedSprite = $Sprite
onready var range_area: Area2D = $Range
onready var range_radius: CollisionShape2D = $Range/Area
onready var health_bar = $HealthBar
onready var auras_node = $Auras


################################################################################
# Interface
################################################################################

func cmd_move_to(point: Vector2) -> bool:
    if state == FSM.DYING:
        return false
    under_command = true
    move_waypoint = point
    _enter_walk()
    return true


func cmd_attack_target(target) -> bool:
    if state == FSM.DYING:
        return false
    under_command = true
    _enter_pursuit(target)
    return true


func set_waypoint(point: Vector2):
    move_waypoint = point


func is_alive() -> bool:
    return health > 0 and state != FSM.DYING


func is_idle() -> bool:
    return state == FSM.IDLE


func take_attack(damage: int, typed: int, source: WeakRef) -> int:
    if dodge_chance > 0.0:
        if randf() < dodge_chance:
            return 0
    return take_damage(damage, typed, source)


func take_damage(damage: int, typed: int, source: WeakRef) -> int:
    var bonus: int = 0
    match typed:
        Global.DamageTypes.PHYSICAL:
            bonus = Global.calc_armor_bonus(armor_type, damage)
            if armor_bonuses > 0:
                bonus -= Global.calc_aura_damage_bonus(damage)
        Global.DamageTypes.MAGIC:
            bonus = Global.calc_magic_resist_bonus(magic_resistance, damage)
            if magic_resist_bonuses > 0:
                bonus -= Global.calc_aura_damage_bonus(damage)
        Global.DamageTypes.HERO:
            pass
        _:
            assert(false, 'unexpected damage type')
    damage += bonus
    damage = max(1, damage) as int
    return take_final_damage(damage, typed, source)


func take_physical_damage(damage: int, source: WeakRef) -> int:
    return take_damage(damage, Global.DamageTypes.PHYSICAL, source)


func take_magic_damage(damage: int, source: WeakRef) -> int:
    return take_damage(damage, Global.DamageTypes.MAGIC, source)


func take_final_damage(damage: int, typed: int, _source: WeakRef) -> int:
    if state == FSM.DYING:
        return 0
    health -= damage
    emit_signal("took_damage", damage, typed)
    if health <= 0:
        _enter_dying()
    health_bar.set_value(health, max_health)
    return damage


func do_attack():
    assert(attack_target != null)
    var target = attack_target.get_ref()
    if not target:
        return
    if projectile == Global.Projectiles.NONE:
        var damage = _calc_damage_output()
        damage = target.take_attack(damage, damage_type, weakref(self))
        if weapon_type == Global.WeaponTypes.SPLASH:
            var splash = Global.calc_aura_damage_bonus(damage)
            for other in target._get_melee_allies():
                other.take_damage(splash, damage_type, weakref(self))
        if melee_lifesteal_effects > 0:
            damage = Global.calc_lifesteal_health(damage)
            heal(damage)
    else:
        emit_signal("spawn_projectile", projectile, self, target)


func heal(damage: int):
    if health < max_health:
        health += damage
        if health > max_health:
            health = max_health
        emit_signal("healed_damage", damage)
        print("Healed %d health" % damage)


################################################################################
# Event Handlers
################################################################################

func _on_Range_body_entered(body):
    if state != FSM.IDLE and state != FSM.WALK and state != FSM.PURSUIT:
        return
    if body.team == team or not body.is_alive():
        return
    if under_command:
        return
    #if state == FSM.PURSUIT:
    #    assert(attack_target != null)
    #    if body != attack_target.get_ref():
    #        return
    #_enter_attack(body)
    if state != FSM.PURSUIT:
        _enter_pursuit(body)


func _on_Range_body_exited(body):
    if not attack_target:
        return
    if body == attack_target.get_ref():
        attack_target = null
        if state == FSM.ATTACK or state == FSM.PURSUIT or state == FSM.COOLDOWN:
            _enter_idle()


func _on_Sprite_animation_finished():
    match state:
        FSM.ATTACK:
            # punch/attack animation finished
            do_attack()
            _enter_cooldown()
        FSM.DYING:
            # death animation finished
            queue_free()


################################################################################
# Life Cycle
################################################################################

func _ready():
    collision_layer = Global.get_collision_layer(team)
    collision_mask = Global.get_collision_mask(team)
    range_area.collision_mask = Global.get_collision_mask_all_teams()
    _init_from_data(base_data)
    health = max_health
    health_bar.set_value(health, max_health)
    sprite.animation = Global.ANIM_IDLE


func _process(delta: float):
    match state:
        FSM.IDLE:
            _process_idle(delta)
        FSM.ATTACK:
            _process_attack(delta)
        FSM.PURSUIT:
            _process_pursuit(delta)
        FSM.COOLDOWN:
            _process_cooldown(delta)
        _:
            pass
    if state != FSM.DYING:
        _process_ticks(delta)


func _physics_process(delta: float):
    match state:
        FSM.WALK:
            _physics_process_walk(delta)
        FSM.PURSUIT:
            _physics_process_pursuit(delta)
        _:
            pass


################################################################################
# Idle State
################################################################################


func _enter_idle():
    # print(name, " --> IDLE")
    state = FSM.IDLE
    sprite.animation = Global.ANIM_IDLE
    attack_target = null
    under_command = false


func _process_idle(_delta):
#    timer -= delta
#    if timer > 0:
#        return
#    delta = -timer
#    timer = 0
    var target = _check_for_enemies()
    if target != null:
        # _enter_attack(target)
        # return _process_attack(delta)
        return _enter_pursuit(target)
    if move_waypoint != null:
        _enter_walk()


################################################################################
# Walking State
################################################################################


func _enter_walk():
    # print(name, " --> WALK")
    state = FSM.WALK
    sprite.animation = Global.ANIM_WALK
    attack_target = null


func _physics_process_walk(_delta):
    if move_waypoint == null:
        return
    var moved = _physics_move_to(move_waypoint)
    if not moved:
        _enter_idle()


################################################################################
# Attack State
################################################################################


func _enter_attack(target: Node2D):
    # print(name, " --> ATTACK")
    assert(target.team != team)
    state = FSM.ATTACK
    attack_target = weakref(target)
    # sprite.animation = Global.ANIM_CAST if is_caster else Global.ANIM_ATTACK
    sprite.animation = Global.ANIM_ATTACK
    sprite.flip_h = target.position.x < position.x
    timer = attack_speed
    if attack_speed_bonuses > 0:
        timer = Global.calc_attack_speed_bonus(attack_speed)


func _process_attack(delta: float):
    assert(timer > 0)
    timer -= delta
    if timer <= 0:
        timer = 0
        # ready to attack
        delta = -timer
        _enter_cooldown()
        _process_cooldown(delta)


################################################################################
# Cooldown State
################################################################################


func _enter_cooldown():
    # print(name, " --> COOLDOWN")
    state = FSM.COOLDOWN
    sprite.animation = Global.ANIM_IDLE


func _process_cooldown(delta: float):
    timer -= delta
    if timer > 0:
        return
    delta = -timer
    timer = 0
    var target = attack_target.get_ref()
    # if target and range_area.overlaps_body(target):
    if target and position.distance_to(target.position) <= attack_range:
        _enter_attack(target)
        _process_attack(delta)
    else:
        _enter_idle()
        _process_idle(delta)


################################################################################
# Pursuit State
################################################################################


func _enter_pursuit(target: Node2D):
    # print(name, "  --> PURSUIT")
    assert(target.team != team)
    # if range_area.overlaps_body(target):
    if position.distance_to(target.position) <= attack_range:
        _enter_attack(target)
    else:
        state = FSM.PURSUIT
        leash.x = position.x
        leash.y = position.y
        attack_waypoint = target.position
        attack_target = weakref(target)
        sprite.animation = Global.ANIM_WALK
        sprite.flip_h = target.position.x < position.x


func _process_pursuit(delta: float):
    assert(attack_target != null)
    var target = attack_target.get_ref()
    if not target:
        _enter_idle()
        _process_idle(delta)
    elif position.distance_to(target.position) <= attack_range:
        _enter_attack(target)
        _process_attack(delta)
    elif position.distance_to(leash) >= Global.AGGRO_RANGE:
        var _discard = cmd_move_to(leash)


func _physics_process_pursuit(_delta):
    assert(attack_target != null)
    var target = attack_target.get_ref()
    if not target:
        _enter_idle()
        return
    attack_waypoint = target.position
    var moved = _physics_move_to(attack_waypoint)
    if not moved or velocity.length_squared() < 1:
        _enter_idle()


################################################################################
# Dying State
################################################################################


func _enter_dying():
    # print(name, " --> DYING")
    state = FSM.DYING
    health = 0
    power = 0
    move_speed = 0
    move_waypoint = null
    attack_waypoint = null
    attack_target = null
    under_command = false
    velocity = Vector2.ZERO
    sprite.animation = Global.ANIM_DEATH
    emit_signal("died")


################################################################################
# Helper Functions
################################################################################

func _init_from_data(data: MinionData):
    sprite.frames = data.get_sprite_frames(team_colour)
    cost = data.cost
    max_health = Global.calc_health(data.health)
    power = Global.calc_power(data.power)
    # move_speed = Global.calc_move_speed(data.move_speed)
    move_speed = data.move_speed
    attack_speed = Global.calc_attack_speed(data.attack_speed)
    #attack_range = Global.calc_attack_range(data.attack_range)
    attack_range = data.attack_range
    range_radius.shape.radius = max(Global.AGGRO_RANGE, attack_range)
    projectile = data.projectile
    weapon_type = data.weapon_type
    damage_type = data.damage_type
    armor_type = data.armor_type
    magic_resistance = data.magic_resistance

    if data.ability > Global.Abilities.AURAS_START and data.ability < Global.Abilities.AURAS_END:
        var aura = SCN_AURA.instance()
        aura.ability = data.ability
        aura.set_team(team)
        aura.team_colour = team_colour
        auras_node.add_child(aura)
    elif data.ability == Global.Abilities.EVASION:
        dodge_chance = Global.EVASION_DODGE_CHANCE


func _physics_move_to(waypoint: Vector2) -> bool:
    velocity = _aim(waypoint)
    if velocity == Vector2.ZERO:
        return false
    sprite.flip_h = velocity.x < 0
    var s = move_speed
    if move_speed_bonuses > 0:
        s += Global.MOVE_SPEED_BONUS
    velocity *= s
    velocity = move_and_slide(velocity)
    return true


func _aim(target: Vector2) -> Vector2:
    if position.distance_squared_to(target) < 4:
        return Vector2.ZERO
    return (target - position).normalized()


func _aim2(target: Vector2) -> Vector2:
    var dx = target.x - position.x
    var dy = target.y - position.y
    if dx < -EPSILON:
        if dy < -EPSILON:
            return Global.NORTHWEST
        if dy > EPSILON:
            return Global.SOUTHWEST
        return Global.WEST
    if dx > EPSILON:
        if dy < -EPSILON:
            return Global.NORTHEAST
        if dy > EPSILON:
            return Global.SOUTHEAST
        return Global.EAST
    if dy < -EPSILON:
        return Global.NORTH
    if dy > EPSILON:
        return Global.SOUTH
    return Vector2.ZERO


func _check_for_enemies():
    for target in range_area.get_overlapping_bodies():
        if target == self or target.team == team or not target.is_alive():
            continue
        return target
    return null


func _get_melee_allies() -> Array:
    var others = []
    var r = Global.get_melee_range()
    for target in range_area.get_overlapping_bodies():
        if target == self or target.team != team or not target.is_alive():
            continue
        if position.distance_to(target.position) > r:
            continue
        others.append(target)
    return others


func _calc_damage_output() -> int:
    var damage = power
    if damage_type == Global.DamageTypes.PHYSICAL:
        if physical_damage_bonuses > 0:
            damage += Global.calc_aura_damage_bonus(damage)
        elif physical_damage_bonuses < 0:
            damage -= Global.calc_aura_damage_bonus(damage)
            damage = max(1, damage)
    elif damage_type == Global.DamageTypes.MAGIC:
        if magic_damage_bonuses > 0:
            damage += Global.calc_aura_damage_bonus(damage)
        elif magic_damage_bonuses < 0:
            damage -= Global.calc_aura_damage_bonus(damage)
            damage = max(1, damage)
    return damage


func _process_ticks(delta: float):
    tick_timer += delta
    while tick_timer >= 1.0:
        tick_timer -= 1.0
        if health_regen_effects > 0:
            heal(Global.PASSIVE_HEALTH_REGEN)
