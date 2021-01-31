extends Container
class_name Page

func _on_activated() -> void:
    pass

func _on_deactivated() -> void:
    pass

func get_is_active() -> bool:
    return Nav.current_page == self
