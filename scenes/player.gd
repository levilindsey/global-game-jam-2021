extends KinematicBody2D
class_name Player

const Bit := preload("res://scenes/bit.tscn")

export (int) var size = 2
var velocity = Vector2.ZERO

const HORIZONTAL_VEL = 300.0
const HORIZONTAL_ACCEL = 10 # How quickly we accelerate to max speed
const JUMP_ACCEL = 700.0
const DASH_ACCEL = 950.0
const GRAVITY = 30.0
const TERM_VEL = JUMP_ACCEL * 2

const DEFAULT_BIT_SIZE = 1
const DEFAULT_SPRITE_SCALE = Vector2(0.006, 0.006)

const JUMP_TIME = 0.25
const DASH_TIME = 0.15
const DASH_GRAVITY = 0.5  # Percentage of normal gravity

var is_dashing = false
var dash_duration_remaining = 0.0
var jump_duration_remaining = 0.0

var facing_right = true

func _ready():
    _update_size()

func _physics_process(delta):
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
    
    # Apply gravity, but less so when dashing
    velocity.y = min(TERM_VEL, velocity.y + GRAVITY) * (DASH_GRAVITY * int(is_dashing) + (1 - int(is_dashing)))
    if jump_duration_remaining > 0:
        jump_duration_remaining -= delta
        if jump_duration_remaining < 0 or Input.is_action_just_released("jump"):
            jump_duration_remaining = 0.0
            velocity.y *= 0.5
    
    # Lerp horizontal movement
    var horizontal_accel = HORIZONTAL_ACCEL
    if abs(velocity.x) > abs(target_horizontal):
        horizontal_accel = HORIZONTAL_ACCEL * 0.1

    # Special case for dashing
    if is_dashing:
        dash_duration_remaining -= delta
        if dash_duration_remaining <= 0:
            is_dashing = false
    else:
        velocity.x = lerp(velocity.x, target_horizontal, HORIZONTAL_ACCEL * delta)
    
    velocity = move_and_slide(velocity, Vector2.UP)
    
    _update_size()
    _update_sprite_flip()

func _jump():
    jump_duration_remaining = JUMP_TIME
    velocity.y = -JUMP_ACCEL
    _emit()
    Sfx.play(Sfx.JUMP)

func _dash():
    is_dashing = true
    dash_duration_remaining = DASH_TIME
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
    bit.velocity = -velocity * 0.5
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
        if body.spiky or size < body.size:
            Nav.get_level_page().reset()
        else:
            size += body.size
            body.destroy()
