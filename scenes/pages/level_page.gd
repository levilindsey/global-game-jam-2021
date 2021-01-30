extends Page
class_name LevelPage

enum {
    LEVEL_1,
}

var _LEVEL_PACKED_SCENES := {
    # Change to your own kitchensink scene!
    LEVEL_1: preload("res://scenes/kitchensink_connie.tscn"),
}

var level_type := LEVEL_1
var level: Node2D

func _on_activated() -> void:
    ._on_activated()
    level = _LEVEL_PACKED_SCENES[level_type].instance()
    add_child(level)

func _on_deactivated() -> void:
    ._on_deactivated()
    level.queue_free()
