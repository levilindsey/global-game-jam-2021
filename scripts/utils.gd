extends Node

const FLOOR_MAX_ANGLE := 45.0 * PI / 180.0

enum {
    NONE,
    FLOOR,
    CEILING,
    LEFT_WALL,
    RIGHT_WALL,
}

static func concat(result: Array, other: Array) -> void:
    var old_result_size := result.size()
    var other_size := other.size()
    result.resize(old_result_size + other_size)
    for i in range(other_size):
        result[old_result_size + i] = other[i]

static func get_children_by_type(parent: Node, type, recursive := false) -> Array:
    var result = []
    for child in parent.get_children():
        if child is type:
            result.push_back(child)
        if recursive:
            concat(result, get_children_by_type(child, type, recursive))
    return result

static func get_child_by_type(parent: Node, type, recursive := false) -> Node:
    var children := get_children_by_type(parent, type, recursive)
    assert(children.size() == 1)
    return children[0]

static func get_which_wall_collided_for_body(body: KinematicBody2D) -> int:
    if body.is_on_wall():
        for i in range(body.get_slide_count()):
            var collision := body.get_slide_collision(i)
            var side := get_which_surface_side_collided(collision)
            if side == LEFT_WALL or side == RIGHT_WALL:
                return side
    return NONE

static func get_which_surface_side_collided(collision: KinematicCollision2D) -> int:
    if abs(collision.normal.angle_to(Vector2.UP)) <= FLOOR_MAX_ANGLE:
        return FLOOR
    elif abs(collision.normal.angle_to(Vector2.DOWN)) <= FLOOR_MAX_ANGLE:
        return CEILING
    elif collision.normal.x > 0:
        return LEFT_WALL
    else:
        return RIGHT_WALL
