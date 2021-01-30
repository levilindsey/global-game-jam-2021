extends RigidBody2D
class_name Bit

export var size := 1

const DEFAULT_RADIUS := 10.0

var i_was_eaten := false

func _ready() -> void:
    var circle := CircleShape2D.new()
    circle.radius = get_radius()
    $CollisionShape2D.shape = circle

func _physics_process(_delta):
    _update_size()

func get_radius():
    return DEFAULT_RADIUS * sqrt(size)

func _update_size():
    $CollisionShape2D.shape.radius = get_radius()

func destroy():
    queue_free()
    i_was_eaten = true

func _on_Bit_body_entered(body: Node) -> void:
    if body.is_in_group("bits") and !i_was_eaten:
        size += body.size
        body.destroy()
