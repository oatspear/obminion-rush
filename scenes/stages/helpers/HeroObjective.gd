extends Area2D

################################################################################
# Constants
################################################################################

const IDLE_LIMIT = 1.0  # secs

################################################################################
# Signals
################################################################################

signal captured()

################################################################################
# Variables
################################################################################

export (int) var team: int = 0

var hero: WeakRef
var timer: float = 0

################################################################################
# Interface
################################################################################

func has_hero() -> bool:
    return hero != null and hero.get_ref() != null


func set_hero(minion: Node2D):
    if hero != null:
        var prev = hero.get_ref()
        if prev:
            prev.disconnect("died", self, "_on_hero_died")
    hero = weakref(minion)
    var _np = minion.connect("died", self, "_on_hero_died")


################################################################################
# Life Cycle
################################################################################

func _process(delta: float):
    if not has_hero():
        return
    var m = hero.get_ref()
    if m.is_idle():
        timer += delta
        if timer >= IDLE_LIMIT:
            m.cmd_move_to(position)
    else:
        timer = 0


################################################################################
# Events
################################################################################

func _on_hero_died(killer):
    hero = null
    emit_signal("captured", killer)


func _on_HeroObjective_body_entered(body):
    if hero == null:
        return
    var this_hero = hero.get_ref()
    if not this_hero:
        return
    if body.team != team:
        pass # body.cmd_attack_target(this_hero)
    else:
        # assist
        pass


func _on_HeroObjective_body_exited(body):
    if not hero or body != hero.get_ref():
        return
    body.cmd_move_to(position)
