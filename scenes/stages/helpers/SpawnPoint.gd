extends Position2D

################################################################################
# Variables
################################################################################

export (int) var team: int = 0

export (NodePath) var waypoint

export (float) var random_distance: float = 5.0
export (bool) var random_h: bool = true
export (bool) var random_v: bool = false


################################################################################
# Interface
################################################################################

func get_waypoint() -> Vector2:
    return get_node(waypoint).position


func get_random_position() -> Vector2:
    if random_distance == 0 or (not random_h and not random_v):
        return position
    var p = Vector2(position.x, position.y)
    if random_h:
        p.x += rand_range(-random_distance, random_distance)
    if random_v:
        p.y += rand_range(-random_distance, random_distance)
    return p
