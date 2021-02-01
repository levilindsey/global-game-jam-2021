extends Page
class_name MainMenuPage

#const TITLE_IMAGE_SIZE_DEFAULT := Vector2(1024, 600)
#
#func _ready():
#    _on_size_changed()
#    get_viewport().connect( \
#            "size_changed", \
#            self, \
#            "_on_size_changed")
#
#func _on_size_changed():
#    var viewport_size := get_viewport().size
#    var display_scale: Vector2 = Nav.DEFAULT_DISPLAY_SIZE / viewport_size
#    var title_scale := viewport_size / TITLE_IMAGE_SIZE_DEFAULT
#    $TextureRect.rect_size = title_scale

func _input(event):
    var is_key_press: bool = event is InputEventKey and !event.pressed
    var is_mouse_press: bool = event is InputEventMouseButton and !event.pressed
    if get_is_active() and (is_key_press or is_mouse_press):
        Nav.open(Nav.CONTROLS_PAGE)
