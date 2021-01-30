extends RigidBody2D
class_name Bit

export var size := 1

const DEFAULT_RADIUS := 5.0

func _physics_process(delta):
    _update_size()

func get_radius():
    return DEFAULT_RADIUS * sqrt(size)

func _update_size():
    $CollisionShape2D.shape.radius = get_radius()

func destroy():
    queue_free()
