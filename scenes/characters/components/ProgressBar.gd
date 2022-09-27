extends Sprite

const THRESHOLDS = [
    13 * 100.0 / 14,
    12 * 100.0 / 14,
    11 * 100.0 / 14,
    10 * 100.0 / 14,
    9 * 100.0 / 14,
    8 * 100.0 / 14,
    7 * 100.0 / 14,
    6 * 100.0 / 14,
    5 * 100.0 / 14,
    4 * 100.0 / 14,
    3 * 100.0 / 14,
    2 * 100.0 / 14,
    1 * 100.0 / 14,
    0,
]

################################################################################
# Interface
################################################################################

func set_value(value: int, max_value: int):
    if value >= max_value:
        visible = false
        return
    visible = true
    var i = 0
    var x = value * 100.0 / max_value
    for limit in THRESHOLDS:
        if x > limit:
            break
        i += 1
    frame = i
