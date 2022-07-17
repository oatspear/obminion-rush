extends TextureButton

################################################################################
# Variables
################################################################################

export (Resource) var unit_type = null
export (int) var cost: int = 0

onready var unit_icon: AnimatedSprite = $Icon
onready var cost_icon: Sprite = $Cost
onready var overlay: Sprite = $Overlay


################################################################################
# Interface
################################################################################

func set_unit(unit_frames: SpriteFrames, unit_cost: int):
    assert(unit_cost >= 0 and unit_cost <= Global.MAX_UNIT_COST)
    cost = unit_cost
    unit_icon.frames = unit_frames
    set_available(not disabled)


func set_available(available: bool = true):
    disabled = not available
    if available:
        unit_icon.animation = Global.ANIM_IDLE
    else:
        unit_icon.animation = Global.ANIM_SNOOZE
    _refresh_cost()


func enable():
    disabled = false
    overlay.visible = false
    _refresh_cost()

func disable():
    disabled = true
    overlay.visible = true
    var r = randi() % 4
    overlay.flip_h = r % 2 == 0
    overlay.flip_v = r >= 2
    _refresh_cost()


func set_cost(unit_cost: int):
    cost = unit_cost
    _refresh_cost()


################################################################################
# Life Cycle
################################################################################

func _ready():
    overlay.visible = disabled
    _refresh_cost()


func _refresh_cost():
    if cost <= 0:
        cost_icon.visible = false
    else:
        cost_icon.visible = true
        cost_icon.frame = 2 * (cost - 1) + (1 if disabled else 0)
