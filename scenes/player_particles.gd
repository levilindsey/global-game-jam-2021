extends Node2D
class_name PlayerParticles

enum {
    BIT_EXPLODE_EFFECT,
    BLOB_DASH_EFFECT,
    BLOB_EXPLODE_EFFECT,
    BLOB_JUMP_EFFECT,
    ENEMY_EXPLODE_EFFECT,
}

const EFFECT_ANIMATION_PACKED_SCENES := {
    BIT_EXPLODE_EFFECT: preload("res://scenes/effects_animations/bit_explode_effect_animation.tscn"),
    BLOB_DASH_EFFECT: preload("res://scenes/effects_animations/blob_dash_effect_animation.tscn"),
    BLOB_EXPLODE_EFFECT: preload("res://scenes/effects_animations/blob_explode_effect_animation.tscn"),
    BLOB_JUMP_EFFECT: preload("res://scenes/effects_animations/blob_jump_effect_animation.tscn"),
    ENEMY_EXPLODE_EFFECT: preload("res://scenes/effects_animations/enemy_explode_effect_animation.tscn"),
}

var level_page

# Dictionary<Node2D, Node2D>
var effects := {}

func play( \
        effect: int, \
        node: Node, \
        horizontal_sign := 0) -> void:
    var scale_x_sign: int = \
            horizontal_sign if \
            horizontal_sign != 0 else \
            pow(-1, randi() % 2)
    
    var effect_animator: Node2D = EFFECT_ANIMATION_PACKED_SCENES[effect].instance()
    level_page.add_child(effect_animator)
    effect_animator.position = effect_animator.calc_position(node, horizontal_sign)
    effect_animator.scale = Vector2(scale_x_sign, 1) * effect_animator.calc_scale(node)
    
    var sprite: AnimatedSprite = effect_animator.get_node("AnimatedSprite")
    sprite.frame = 0
    sprite.connect( \
            "animation_finished", \
            self, \
            "_on_animation_finished", \
            [effect_animator])
    sprite.play()
    
    effects[effect_animator] = effect_animator

func _on_animation_finished(effect_animator: Node2D) -> void:
    level_page.remove_child(effect_animator)
    effect_animator.queue_free()
    effects.erase(effect_animator)
