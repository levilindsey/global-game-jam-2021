extends Node

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
