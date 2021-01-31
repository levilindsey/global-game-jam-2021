extends KinematicBody2D
class_name Player

const Bit := preload("res://scenes/bit.tscn")

export (int) var size = 2 setget _set_size,_get_size
var velocity = Vector2.ZERO

const HORIZONTAL_VEL = 300.0
const HORIZONTAL_ACCEL = 10 # How quickly we accelerate to max speed
const JUMP_ACCEL = 700.0
const DASH_ACCEL = 950.0
const GRAVITY = 30.0
const TERM_VEL = JUMP_ACCEL * 2

const DEFAULT_BIT_SIZE = 1

const JUMP_TIME = 0.25
const DASH_TIME = 0.15
const DASH_GRAVITY = 0.5  # Percentage of normal gravity

var is_dashing = false
var dash_duration_remaining = 0.0
var jump_duration_remaining = 0.0

var facing_right = true
var is_airborne = false
var is_moving = false
var was_on_floor = false
var was_on_ceiling = false
var was_on_wall = false

onready var launch_tween = Tween.new()
const LAUNCH_SCALE_MULTIPLIER := Vector2(0.85, 1.15)
const LAUNCH_DURATION_SEC := 0.25

onready var impact_tween = Tween.new()
const IMPACT_SCALE_MULTIPLIER := Vector2(1.25, 0.75)
const IMPACT_DURATION_SEC := 0.25

onready var growth_tween = Tween.new()
const GROWTH_SCALE_MULTIPLIER := Vector2(1.25, 0.95)
const GROWTH_DURATION_SEC := 0.25

onready var particles := PlayerParticles.new()

var _is_ready := false

enum SpriteVariants {
    IDLE,
    MOVE,
    AIR,
}
const BLOB_SPRITE_IDLE = preload("res://assets/images/player_idle_blob.png")
const BLOB_SPRITE_MOVE = preload("res://assets/images/player_move_blob.png")
const BLOB_SPRITE_AIR = preload("res://assets/images/player_air_blob.png")
const CORE_SPRITE_IDLE = preload("res://assets/images/player_idle_core.png")
const CORE_SPRITE_MOVE = preload("res://assets/images/player_move_core.png")
const CORE_SPRITE_AIR = preload("res://assets/images/player_air_core.png")

func _ready():
    _is_ready = true
    _update_size()
    particles.player = self
    particles.level_page = Nav.get_level_page()
    add_child(particles)
    add_child(launch_tween)
    add_child(impact_tween)
    add_child(growth_tween)

func _physics_process(delta):
    var target_horizontal = 0
    if Input.is_action_pressed("move_left"):
        target_horizontal -= HORIZONTAL_VEL
    if Input.is_action_pressed("move_right"):
        target_horizontal += HORIZONTAL_VEL
    if !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right"):
        is_moving = false
    else:
        is_moving = true
    
    if target_horizontal != 0:
        facing_right = target_horizontal > 0

    if Input.is_action_just_pressed("jump") and size > 1:
        _jump()
    if Input.is_action_just_pressed("dash") and size > 1:
        _dash()
    
    if not was_on_floor and is_on_floor():
        _impact(Utils.FLOOR)
    if not was_on_ceiling and is_on_ceiling():
        _impact(Utils.CEILING)
    if not was_on_wall and is_on_wall():
        _impact(Utils.get_which_wall_collided_for_body(self))
    
    was_on_floor = is_on_floor()
    was_on_ceiling = is_on_ceiling()
    was_on_wall = is_on_wall()
    
    # Apply gravity, but less so when dashing
    velocity.y = min(TERM_VEL, velocity.y + GRAVITY) * (DASH_GRAVITY * int(is_dashing) + (1 - int(is_dashing)))
    if jump_duration_remaining > 0:
        jump_duration_remaining -= delta * Constants.TIME_SCALE
        if jump_duration_remaining < 0 or Input.is_action_just_released("jump"):
            jump_duration_remaining = 0.0
            velocity.y *= 0.5
    
    # Lerp horizontal movement
    var horizontal_accel = HORIZONTAL_ACCEL
    if abs(velocity.x) > abs(target_horizontal):
        horizontal_accel = HORIZONTAL_ACCEL * 0.05

    # Special case for dashing
    if is_dashing:
        dash_duration_remaining -= delta * Constants.TIME_SCALE
        if dash_duration_remaining <= 0:
            is_dashing = false
    else:
        velocity.x = lerp(velocity.x, target_horizontal, HORIZONTAL_ACCEL * delta)
    
    _update_move_sprite()

    var previous_y = velocity.y
    velocity = move_and_slide(velocity * Constants.TIME_SCALE, Vector2.UP)
    
    # Impact from a large fall.
    if abs(velocity.y - previous_y) >= TERM_VEL - 100:
        $Camera2D.shake(0.4, 20, size)
    
    velocity /= Constants.TIME_SCALE
    
    _update_sprite_flip()
    _check_tile()

func _jump():
    jump_duration_remaining = JUMP_TIME
    is_airborne = true
    velocity.y = -JUMP_ACCEL
    _emit()
    Sfx.play(Sfx.JUMP)
    _update_sprite(SpriteVariants.AIR)
    _launch(false)

func _update_move_sprite():
    if not is_airborne:
        if not is_moving:
            _update_sprite(SpriteVariants.IDLE)
        else:
            _update_sprite(SpriteVariants.MOVE)

func _update_sprite(variant):
    if variant == SpriteVariants.IDLE:
        $Sprite.texture = BLOB_SPRITE_IDLE
        $core.texture = CORE_SPRITE_IDLE
    elif variant == SpriteVariants.MOVE:
        $Sprite.texture = BLOB_SPRITE_MOVE
        $core.texture = CORE_SPRITE_MOVE
    elif variant == SpriteVariants.AIR:
        $Sprite.texture = BLOB_SPRITE_AIR
        $core.texture = CORE_SPRITE_AIR

func _dash():
    is_dashing = true
    dash_duration_remaining = DASH_TIME
    $Camera2D.shake(0.2, 10, 2)
    velocity.y = 0
    if facing_right:
        velocity.x = DASH_ACCEL
    else:
        velocity.x = -DASH_ACCEL
    _emit()
    # TODO: Replace with dash sfx
    Sfx.play(Sfx.JUMP)
    particles.play(PlayerParticles.DASH_EFFECT, _get_horizontal_sign())
    _launch(true)

func _emit():
    var bit_size = DEFAULT_BIT_SIZE
    _set_size(size - bit_size)
    var level = get_tree().get_nodes_in_group('levels')[0]
    
    var bit = Bit.instance()
    level.add_child(bit)
    bit.size = bit_size
    bit.velocity = -velocity * 0.5
    bit.position = position - (_get_radius() + bit.get_radius() + 0.1) * velocity.normalized()

func _launch(is_dash):
    var scale_multiplier = LAUNCH_SCALE_MULTIPLIER
    var displacement = Vector2(0.0, _get_radius() * (scale_multiplier.y - 1.0))
    if is_dash:
        scale_multiplier = Vector2(LAUNCH_SCALE_MULTIPLIER.y, LAUNCH_SCALE_MULTIPLIER.x)
        displacement = Vector2(_get_radius() * (scale_multiplier.y - 1.0) * _get_horizontal_sign(), 0.0)

    var duration_a := LAUNCH_DURATION_SEC / Constants.TIME_SCALE * 0.25
    var duration_b := LAUNCH_DURATION_SEC / Constants.TIME_SCALE - duration_a
    launch_tween.stop_all()
    impact_tween.stop_all()
    growth_tween.stop_all()
    launch_tween.interpolate_method(
            self,
            "_interpolate_scale",
            Vector2.ONE,
            scale_multiplier,
            duration_a,
            Tween.TRANS_SINE,
            Tween.EASE_OUT)
    launch_tween.interpolate_property(
            $Sprite,
            "position",
            Vector2.ZERO,
            displacement,
            duration_a,
            Tween.TRANS_SINE,
            Tween.EASE_OUT)
    launch_tween.interpolate_method(
            self,
            "_interpolate_scale",
            scale_multiplier,
            Vector2.ONE,
            duration_b,
            Tween.TRANS_BACK,
            Tween.EASE_OUT,
            duration_a)
    launch_tween.interpolate_property(
            $Sprite,
            "position",
            displacement,
            Vector2.ZERO,
            duration_b,
            Tween.TRANS_BACK,
            Tween.EASE_OUT,
            duration_a)
    launch_tween.start()

func _land():
    is_airborne = false
    _update_sprite(SpriteVariants.MOVE)

func _impact(side: int):
    if side == Utils.FLOOR:
        _land()
    var scale_multiplier = IMPACT_SCALE_MULTIPLIER
    var displacement: Vector2
    match side:
        Utils.FLOOR:
            displacement = Vector2(0.0, _get_radius() * (1.0 - scale_multiplier.y))
        Utils.CEILING:
            displacement = Vector2(0.0, _get_radius() * (scale_multiplier.y - 1.0))
        Utils.LEFT_WALL:
            scale_multiplier = Vector2(IMPACT_SCALE_MULTIPLIER.y, IMPACT_SCALE_MULTIPLIER.x)
            displacement = Vector2(_get_radius() * (1.0 - scale_multiplier.y), 0.0)
        Utils.RIGHT_WALL:
            scale_multiplier = Vector2(IMPACT_SCALE_MULTIPLIER.y, IMPACT_SCALE_MULTIPLIER.x)
            displacement = Vector2(_get_radius() * (scale_multiplier.y - 1.0), 0.0)
        _:
            assert(false)
    
    var duration_a := IMPACT_DURATION_SEC / Constants.TIME_SCALE * 0.25
    var duration_b := IMPACT_DURATION_SEC / Constants.TIME_SCALE - duration_a
    launch_tween.stop_all()
    impact_tween.stop_all()
    growth_tween.stop_all()
    impact_tween.interpolate_method(
            self,
            "_interpolate_scale",
            Vector2.ONE,
            scale_multiplier,
            duration_a,
            Tween.TRANS_QUAD,
            Tween.EASE_OUT)
    impact_tween.interpolate_property(
            $Sprite,
            "position",
            Vector2.ZERO,
            displacement,
            duration_a,
            Tween.TRANS_QUAD,
            Tween.EASE_OUT)
    impact_tween.interpolate_method(
            self,
            "_interpolate_scale",
            scale_multiplier,
            Vector2.ONE,
            duration_b,
            Tween.TRANS_BACK,
            Tween.EASE_OUT,
            duration_a)
    impact_tween.interpolate_property(
            $Sprite,
            "position",
            displacement,
            Vector2.ZERO,
            duration_b,
            Tween.TRANS_BACK,
            Tween.EASE_OUT,
            duration_a)
    impact_tween.start()

func _grow(size_delta: int):
    var old_radius := _get_radius()
    _set_size(size + size_delta)
    var new_radius := _get_radius()
    
    var start_multiplier = Vector2.ONE * old_radius / new_radius
    var middle_multiplier = GROWTH_SCALE_MULTIPLIER
    var end_multiplier = Vector2.ONE
    var displacement = Vector2(0.0, 0.0)
    
    var duration_a := GROWTH_DURATION_SEC / Constants.TIME_SCALE * 0.25
    var duration_b := GROWTH_DURATION_SEC / Constants.TIME_SCALE - duration_a
    launch_tween.stop_all()
    impact_tween.stop_all()
    growth_tween.stop_all()
    impact_tween.interpolate_method(
            self,
            "_interpolate_scale",
            start_multiplier,
            middle_multiplier,
            duration_a,
            Tween.TRANS_QUAD,
            Tween.EASE_OUT)
    impact_tween.interpolate_property(
            $Sprite,
            "position",
            Vector2.ZERO,
            displacement,
            duration_a,
            Tween.TRANS_QUAD,
            Tween.EASE_OUT)
    impact_tween.interpolate_method(
            self,
            "_interpolate_scale",
            middle_multiplier,
            end_multiplier,
            duration_b,
            Tween.TRANS_BACK,
            Tween.EASE_OUT,
            duration_a)
    impact_tween.interpolate_property(
            $Sprite,
            "position",
            displacement,
            Vector2.ZERO,
            duration_b,
            Tween.TRANS_BACK,
            Tween.EASE_OUT,
            duration_a)
    impact_tween.start()

func _interpolate_scale(multiplier: Vector2):
    $Sprite.scale = multiplier * Constants.DEFAULT_SPRITE_SCALE * _get_radius()

func _get_radius() -> float:
    return Constants.SIZE_SCALE * sqrt(size)

func _update_size():
    $CollisionShape2D.shape.radius = _get_radius()
    $Area2D/CollisionShape2D.shape.radius = _get_radius()
    $Sprite.scale = Constants.DEFAULT_SPRITE_SCALE * _get_radius()

func _update_sprite_flip():
    $Sprite.flip_h = not facing_right
    $core.flip_h = not facing_right

func _on_Area2D_body_entered(body):
    if body.is_in_group("bits") and body.can_be_eaten:
        _grow(body.size)
        body.destroy()
    if body.is_in_group("enemies"):
        if body.spiky or size < body.size:
            Nav.get_level_page().reset()
        else:
            _grow(body.size)
            body.destroy()

func _check_tile() -> void:
    for i in get_slide_count():
        var collision := get_slide_collision(i)
        if collision.collider is TileMap:
            var tilemap := collision.collider as TileMap
            var tile_pos := tilemap.world_to_map(tilemap.to_local(position))
            tile_pos -= Vector2(round(collision.normal.x), round(collision.normal.y))
            var tile_id := tilemap.get_cellv(tile_pos)
            var tile_name := tilemap.tile_set.tile_get_name(tile_id)
            if tile_name == Constants.SPIKES_TILE_NAME:
                Nav.get_level_page().lose()
            elif tile_name == Constants.GOAL_TILE_NAME:
                Nav.get_level_page().win()

func _set_size(value: int) -> void:
    size = value
    if _is_ready:
        _update_size()

func _get_size() -> int:
    return size

func _get_horizontal_sign() -> int:
    return 1 if facing_right else -1
