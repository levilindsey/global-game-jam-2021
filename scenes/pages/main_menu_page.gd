extends Page
class_name MainMenuPage

func _input(event):
    if get_is_active() and event is InputEventKey and event.pressed:
        Nav.open(Nav.CONTROLS_PAGE)
