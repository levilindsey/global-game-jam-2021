extends RigidBody2D
class_name Enemy

export var size := 3

func _physics_process(_delta):
    _update_size()

func get_radius():
    return Constants.SIZE_SCALE * sqrt(size)

func _update_size():
    $CollisionShape2D.shape.radius = get_radius()

func destroy():
    queue_free()
