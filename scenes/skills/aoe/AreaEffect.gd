extends Area2D

################################################################################
# Constants
################################################################################

const ANIM_SPAWN = "spawn"
const ANIM_EFFECT = "effect"
const ANIM_DEATH = "death"

################################################################################
# Variables
################################################################################

var team: int = 0
var source: WeakRef = null
var effect_active: bool = false

onready var sprite = $Sprite

################################################################################
# Event Handlers
################################################################################


func _ready():
    sprite.play(ANIM_SPAWN)


func _process(delta: float):
    if effect_active:
        _process_effect(delta)


func _on_AreaEffect_body_entered(body):
    return _on_body_entered_effect(body)


func _on_AreaEffect_body_exited(body):
    return _on_body_exited_effect(body)


func _on_AnimatedSprite_animation_finished():
    match sprite.animation:
        ANIM_SPAWN:
            sprite.play(ANIM_EFFECT)
            effect_active = true
            _start_effect()
        ANIM_EFFECT:
            sprite.play(ANIM_DEATH)
            effect_active = false
            _end_effect()
        ANIM_DEATH:
            queue_free()


################################################################################
# Placeholder Methods
################################################################################


func _start_effect():
    pass


func _process_effect(_delta: float):
    pass


func _end_effect():
    pass


func _on_body_entered_effect(_body):
    pass


func _on_body_exited_effect(_body):
    pass
