extends Node2D
class_name PlayerParticles

enum {
    DASH_EFFECT,
}

const EFFECT_ANIMATION_PACKED_SCENES := {
    DASH_EFFECT: preload("res://scenes/effects_animations/dash_effect_animation.tscn"),
}

var player
var level_page

# Dictionary<Node2D, Node2D>
var effects := {}

func play( \
        effect: int, \
        horizontal_sign := 0) -> void:
    var scale_x_sign: int = \
            horizontal_sign if \
            horizontal_sign != 0 else \
            pow(-1, randi() % 2)
    
    var effect_animator: Node2D = EFFECT_ANIMATION_PACKED_SCENES[effect].instance()
    level_page.add_child(effect_animator)
    effect_animator.position = effect_animator.calc_position(player, horizontal_sign)
    effect_animator.scale = Vector2(scale_x_sign, 1) * effect_animator.calc_scale(player)
    
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
