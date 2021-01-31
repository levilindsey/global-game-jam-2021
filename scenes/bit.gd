extends KinematicBody2D
class_name Bit

const SPRITE_SCALE_MULTIPLIER := 0.0100125

export var size := 1 setget _set_size,_get_size

const PRE_EAT_LIFETIME = 0.3
const GRAVITY = 40.0
const TERM_VEL = 500
const HORIZONTAL_ACCEL = 5 # How quickly we accelerate to min speed horizontally

var velocity = Vector2(0, 0)
var i_was_eaten := false

var lifetime = 0
var can_be_eaten = false

var _is_ready := false

const BIT_IDLE = preload("res://assets/images/bit_idle.png")
const BIT_LEAN = preload("res://assets/images/bit_lean.png")
const BIT_AIR = preload("res://assets/images/player_air_blob.png")

func _ready() -> void:
    _is_ready = true
    var circle := CircleShape2D.new()
    $CollisionShape2D.shape = circle
    $Area2D/CollisionShape2D.shape = CircleShape2D.new()
    _update_size()

func _physics_process(delta):
    if lifetime < PRE_EAT_LIFETIME:
        lifetime += delta
    else:
        can_be_eaten = true
    velocity.y = min(TERM_VEL, velocity.y + GRAVITY)
    velocity.x = lerp(velocity.x, 0, HORIZONTAL_ACCEL * delta)
    var was_on_floor = is_on_floor()
    velocity = move_and_slide(velocity, Vector2.UP)
    
    if !was_on_floor and is_on_floor():
        # Landed
        _update_sprite()

func _update_sprite():
    if abs(velocity.x) < 50:
        $Sprite.texture = BIT_IDLE
    else:
        $Sprite.texture = BIT_LEAN
        if velocity.x < 0:
            $Sprite.flip_h = true

func get_radius():
    return Constants.SIZE_SCALE * sqrt(size)

func _update_size():
    $CollisionShape2D.shape.radius = get_radius()
    $Area2D/CollisionShape2D.shape.radius = get_radius()
    $Sprite.scale = get_radius() * Constants.DEFAULT_SPRITE_SCALE #Vector2(SPRITE_SCALE_MULTIPLIER, SPRITE_SCALE_MULTIPLIER)

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
            body._set_size(size + body.size)
            destroy()

func _set_size(value: int) -> void:
    size = value
    if _is_ready:
        _update_size()

func _get_size() -> int:
    return size
