extends Page
class_name PausePage

func _on_Unpause_pressed():
    Nav.open(Nav.LEVEL_PAGE)

func _on_Reset_pressed():
    Nav.get_level_page().reset()
    Nav.open(Nav.LEVEL_PAGE)
