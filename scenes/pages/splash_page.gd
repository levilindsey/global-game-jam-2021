extends Page
class_name SplashPage

const SPLASH_IMAGE_SIZE_DEFAULT := Vector2(900, 835)

func _ready() -> void:
    _on_size_changed()
    get_viewport().connect( \
            "size_changed", \
            self, \
            "_on_size_changed")

func _on_size_changed() -> void:
    var viewport_size := get_viewport().size
    var scale := viewport_size / SPLASH_IMAGE_SIZE_DEFAULT
    if scale.x > scale.y:
        scale.x = scale.y
    else:
        scale.y = scale.x
    var position := -(SPLASH_IMAGE_SIZE_DEFAULT * scale) / 2
    $TextureRect.rect_scale = scale
    $TextureRect.rect_position = position
