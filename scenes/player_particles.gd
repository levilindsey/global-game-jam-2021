extends Node2D
class_name PlayerParticles

enum {
    DASH,
}

var player: Player
var level_page: LevelPage

func play( \
        effect: int, \
        horizontal_sign := 0) -> void:
    var path: String
    match effect:
        DASH:
            path = JUMP_SIDEWAYS_EFFECT_ANIMATION_RESOURCE_PATH
        _:
            Utils.error()
    
    var scale_x_sign: int = \
            horizontal_sign if \
            horizontal_sign != 0 else \
            pow(-1, randi() % 2)
    
    var position: Vector2 = \
            player.position + \
            Vector2(0.0, \
                    Constants.PLAYER_HALF_HEIGHT_DEFAULT * \
                            Constants.PLAYER_SIZE_MULTIPLIER)
    var scale := Vector2(scale_x_sign, 1)
#    scale *= Constants.PLAYER_SIZE_MULTIPLIER
    
    var effect_animator: Node2D = Utils.add_scene( \
            level, \
            path, \
            true, \
            true)
    effect_animator.position = position
    effect_animator.scale = scale
    
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
