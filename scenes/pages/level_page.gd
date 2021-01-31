extends Page
class_name LevelPage

enum {
    LEVEL_1,
    LEVEL_2,
    LEVEL_3,
    LEVEL_4,
    LEVEL_5,
    ZAVEN,
    CONNIE,
    LEVI,
}

var _LEVEL_PACKED_SCENES := {
    LEVEL_1: preload("res://scenes/levels/level_1.tscn"),
    LEVEL_2: preload("res://scenes/levels/level_2.tscn"),
    LEVEL_3: preload("res://scenes/levels/level_3.tscn"),
    LEVEL_4: preload("res://scenes/levels/level_4.tscn"),
    LEVEL_5: preload("res://scenes/levels/level_5.tscn"),
    ZAVEN: preload("res://scenes/levels/level_5.tscn"),
    CONNIE: preload("res://scenes/levels/level_5.tscn"),
    LEVI: preload("res://scenes/levels/level_5.tscn"),
}

const LEVEL_PROGRESSION := [
    LEVEL_1,
    LEVEL_2,
    LEVEL_3,
    LEVEL_4,
    LEVEL_5,
]
# A slight delay to make level switching feel more deliberate.
const LEVEL_SWITCH_DELAY = 0.3
const LOSE_ANIM_DELAY = 0.7


### --- CHANGE THIS TO TEST YOUR LEVEL. --- ###
var level_index := 0


var level: Node2D

func win() -> void:
    print("You win!")
    if LEVEL_PROGRESSION.size() == level_index + 1:
        print("You beat our game!!")
    level_index = min(LEVEL_PROGRESSION.size() - 1, level_index + 1)
    reset()

func lose() -> void:
    print("You lose!")
    reset()

func _fade_out_level():
    var transition = level.get_node("level_logic/transition")
    transition.fade_out()
    yield(transition, "fade_complete")
    yield(get_tree().create_timer(0.7), "timeout")
    level.queue_free()

func reset() -> void:
    if level != null:
        Utils.get_child_by_type(level, Player, true).destroy()
        yield(get_tree().create_timer(LOSE_ANIM_DELAY), "timeout")
        yield(_fade_out_level(), "completed")
    var level_type: int = LEVEL_PROGRESSION[level_index]
    level = _LEVEL_PACKED_SCENES[level_type].instance()
    add_child(level)

func _on_activated() -> void:
    ._on_activated()
    reset()

func _on_deactivated() -> void:
    ._on_deactivated()
    if level != null:
        level.queue_free()
