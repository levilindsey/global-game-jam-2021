extends Node2D
class_name Main

const SPLASH_SCREEN_DURATION_SEC := 1.0

func _ready() -> void:
    Music.pause_mode = PAUSE_MODE_PROCESS
    Screen.pause_mode = PAUSE_MODE_PROCESS
    Nav.pause_mode = PAUSE_MODE_PROCESS
    
    # TODO: Something's wrong with scaling. Fix it before adding this back.  
#    Nav.open(Nav.SPLASH_PAGE)
#    yield(get_tree().create_timer(SPLASH_SCREEN_DURATION_SEC), "timeout")
    
    Nav.open(Nav.MAIN_MENU_PAGE)
#    Nav.open(Nav.LEVEL_PAGE)
