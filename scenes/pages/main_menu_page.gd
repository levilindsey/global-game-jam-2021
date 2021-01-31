extends Page
class_name MainMenuPage

func _input(event):
    var is_key_press: bool = event is InputEventKey and event.pressed
    var is_mouse_press: bool = event is InputEventMouseButton and event.pressed
    if get_is_active() and (is_key_press or is_mouse_press):
        Nav.open(Nav.CONTROLS_PAGE)
