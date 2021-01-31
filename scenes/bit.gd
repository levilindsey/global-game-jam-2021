extends KinematicBody2D
class_name Bit

const SPRITE_SCALE_MULTIPLIER := 0.0150125

export var size := 1 setget _set_size,_get_size

const GRAVITY = 40.0
const TERM_VEL = 500
const HORIZONTAL_ACCEL = 5 # How quickly we accelerate to min speed horizontally

var velocity = Vector2(0, 0)
var i_was_eaten := false

var _is_ready := false

func _ready() -> void:
    _is_ready = true
    var circle := CircleShape2D.new()
    $CollisionShape2D.shape = circle
    _update_size()

func _physics_process(delta):
    velocity.y = min(TERM_VEL, velocity.y + GRAVITY)
    velocity.x = lerp(velocity.x, 0, HORIZONTAL_ACCEL * delta)
    velocity = move_and_slide(velocity, Vector2.UP)

func get_radius():
    return Constants.SIZE_SCALE * sqrt(size)

func _update_size():
    $CollisionShape2D.shape.radius = get_radius()
    $Area2D/CollisionShape2D.shape.radius = get_radius()
    $Sprite.scale = get_radius() * Vector2(SPRITE_SCALE_MULTIPLIER, SPRITE_SCALE_MULTIPLIER)

func destroy():
    i_was_eaten = true
    queue_free()
    
func _on_Area2D_body_entered(body: Node) -> void:
    if body == self:
        return
    if body.is_in_group("bits") and !i_was_eaten and !body.i_was_eaten:
        if position.y > body.position.y:
            _set_size(size + body.size)
            body.destroy()
        else:
            _set_size(size + body.size)
            destroy()

func _set_size(value: int) -> void:
    size = value
    if _is_ready:
        _update_size()

func _get_size() -> int:
    return size
