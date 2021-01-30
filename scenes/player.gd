extends KinematicBody2D
class_name Player

const Bit := preload("res://scenes/bit.tscn")

export (int) var size = 2
var velocity = Vector2.ZERO

const HORIZONTAL_VEL = 300.0
const HORIZONTAL_ACCEL = 10 # How quickly we accelerate to max speed
const JUMP_ACCEL = 500.0
const DASH_ACCEL = 500.0
const GRAVITY = 30.0
const TERM_VEL = JUMP_ACCEL * 2

const DEFAULT_BIT_SIZE = 1
const DEFAULT_SPRITE_SCALE = Vector2(0.006, 0.006)

var facing_right = true

func _ready():
    pass

func _physics_process(_delta):
    var target_horizontal = 0
    if Input.is_action_pressed("move_left"):
        target_horizontal -= HORIZONTAL_VEL
    if Input.is_action_pressed("move_right"):
        target_horizontal += HORIZONTAL_VEL
    
    if target_horizontal != 0:
        facing_right = target_horizontal > 0

    if Input.is_action_just_pressed("jump") and size > 1:
        _jump()
    if Input.is_action_just_pressed("dash") and size > 1:
        _dash()
    
    # Apply gravity
    velocity.y = min(TERM_VEL, velocity.y + GRAVITY)
    
    # Lerp horizontal movement
    var horizontal_accel = HORIZONTAL_ACCEL
    if abs(velocity.x) > abs(target_horizontal):
        horizontal_accel = HORIZONTAL_ACCEL * 0.1

    velocity.x = lerp(velocity.x, target_horizontal, HORIZONTAL_ACCEL * _delta)
    
    velocity = move_and_slide(velocity, Vector2.UP)
    
    _update_size()
    _update_sprite_flip()

func _jump():
    velocity.y = -JUMP_ACCEL
    _emit()
    Sfx.play(Sfx.JUMP)

func _dash():
    velocity.y = 0
    if facing_right:
        velocity.x = DASH_ACCEL
    else:
        velocity.x = -DASH_ACCEL
    _emit()
    # TODO: Replace with dash sfx
    Sfx.play(Sfx.JUMP)

func _emit():
    var bit_size = DEFAULT_BIT_SIZE
    size -= bit_size
    var level = get_tree().get_nodes_in_group('levels')[0]
    
    var bit = Bit.instance()
    level.add_child(bit)
    bit.size = bit_size
    bit.linear_velocity = -velocity * 0.5
    bit.position = position - (_get_radius() + bit.get_radius() + 0.1) * velocity.normalized()

func _get_radius():
    return Constants.SIZE_SCALE * sqrt(size)

func _update_size():
    $CollisionShape2D.shape.radius = _get_radius()
    $Area2D/CollisionShape2D.shape.radius = _get_radius()
    $Sprite.scale = DEFAULT_SPRITE_SCALE * _get_radius()

func _update_sprite_flip():
    $Sprite.flip_h = not facing_right

func _on_Area2D_body_entered(body):
    if body.is_in_group("bits"):
        size += body.size
        body.destroy()
    if body.is_in_group("enemies"):
        if size < body.size:
            Nav.open(Nav.GAME_OVER_PAGE)
        else:
            size += body.size
            body.destroy()
