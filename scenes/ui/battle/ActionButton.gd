extends TextureButton

################################################################################
# Signals
################################################################################

signal reset_cooldown()

################################################################################
# Variables
################################################################################

export (Resource) var unit_type = null
export (int) var cost: int = 0

onready var unit_icon: AnimatedSprite = $Icon
onready var cost_icon: Sprite = $Cost
onready var overlay: Sprite = $Overlay
onready var tween: Tween = $Tween

################################################################################
# Interface
################################################################################

func set_unit(unit_frames: SpriteFrames, unit_cost: int):
    assert(unit_cost >= 0 and unit_cost <= Global.MAX_UNIT_COST)
    unit_icon.frames = unit_frames
    set_cost(unit_cost)
    cost = unit_cost
    if disabled:
        unit_icon.animation = Global.ANIM_IDLE
    else:
        unit_icon.animation = Global.ANIM_ATTACK


func enable():
    if disabled:
        disabled = false
        overlay.visible = false
        unit_icon.animation = Global.ANIM_ATTACK
        _refresh_cost()

func disable():
    if not disabled:
        disabled = true
        overlay.visible = true
        var r = randi() % 4
        overlay.flip_h = r % 2 == 0
        overlay.flip_v = r >= 2
        unit_icon.animation = Global.ANIM_IDLE
        _refresh_cost()


func set_cost(unit_cost: int):
    cost = unit_cost
    _refresh_cost()


func start_cooldown(cooldown: float):
    # tween.stop_all()
    if not tween.is_active():
        disable()
        tween.interpolate_property(unit_icon, "modulate",
            Color.black, Color.white, cooldown,
            Tween.TRANS_LINEAR,
            Tween.EASE_OUT)
        tween.start()


func is_on_cooldown() -> bool:
    return tween.is_active()


################################################################################
# Life Cycle
################################################################################

func _ready():
    overlay.visible = disabled
    _refresh_cost()


################################################################################
# Events
################################################################################

func _on_Tween_tween_all_completed():
    emit_signal("reset_cooldown")


################################################################################
# Helper Functions
################################################################################

func _refresh_cost():
    if cost <= 0:
        cost_icon.visible = false
    else:
        cost_icon.visible = true
        cost_icon.frame = 2 * (cost - 1) + (1 if disabled else 0)
