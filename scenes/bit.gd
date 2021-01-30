tool
extends RigidBody2D
class_name Bit

const SPRITE_SCALE_MULTIPLIER := 0.0150125

export var size := 1

var i_was_eaten := false

func _ready() -> void:
    var circle := CircleShape2D.new()
    $CollisionShape2D.shape = circle
    _update_size()

func _physics_process(_delta):
    _update_size()

func get_radius():
    return Constants.SIZE_SCALE * sqrt(size)

func _update_size():
    $CollisionShape2D.shape.radius = get_radius()
    $Sprite.scale = get_radius() * Vector2(SPRITE_SCALE_MULTIPLIER, SPRITE_SCALE_MULTIPLIER)

func destroy():
    i_was_eaten = true
    queue_free()
    
func _on_Bit_body_entered(body: Node) -> void:
    if body.is_in_group("bits") and !i_was_eaten and !body.i_was_eaten:
        if position.y > body.position.y:
            size += body.size
            body.destroy()
        else:
            body.size += size
            destroy()
