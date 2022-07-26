extends Area2D

################################################################################
# Variables
################################################################################

export (NodePath) var next_waypoint
export (NodePath) var previous_waypoint

################################################################################
# Interface
################################################################################

func get_next_waypoint(team: int) -> Node:
    if team == Global.Teams.BLUE:
        if next_waypoint == null:
            return null
        return get_node(next_waypoint)
    if previous_waypoint == null:
        return null
    return get_node(previous_waypoint)


func _on_Waypoint_body_entered(body):
    if body.follows_lane:
        var p = get_next_waypoint(body.team)
        if p != null:
            body.set_waypoint(p.position)
