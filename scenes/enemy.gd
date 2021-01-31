extends KinematicBody2D
class_name Enemy

export var size := 3 setget _set_size,_get_size
export var spiky = false

var speed := 100.0
var velocity = Vector2.ZERO
var direction = 1
var was_on_wall = false

const GRAVITY = 10.0

var _is_ready := false

func _ready():
    _is_ready = true
    $CollisionShape2D.shape = CircleShape2D.new()
    if spiky:
        $Sprite.texture = preload("res://assets/images/enemy_inedible.png")
    else:
        $Sprite.texture = preload("res://assets/images/enemy_edible.png")
    _update_size()

func _physics_process(_delta):
    _update_direction()
    
    if not $FloorDetectorLeft.is_colliding() and not $FloorDetectorRight.is_colliding():
        velocity.y += GRAVITY
        velocity.x = 0
    else:
        velocity.x = speed * direction
        velocity.y = 0

    velocity = move_and_slide(velocity, Vector2.UP)
    $Sprite.flip_h = direction != 1

func get_radius():
    return Constants.SIZE_SCALE * sqrt(size)

func _update_size():
    var radius = get_radius()
    $CollisionShape2D.shape.radius = radius
    $FloorDetectorLeft.position = Vector2(-radius, radius)
    $FloorDetectorRight.position = Vector2(radius, radius)
    $Sprite.scale = radius * Constants.DEFAULT_SPRITE_SCALE

func _update_direction():
    if not was_on_wall and is_on_wall():
        direction = -direction
    was_on_wall = is_on_wall()
    
    for i in get_slide_count():
        var collision = get_slide_collision(i)
        if (collision.collider != null) and collision.collider.is_in_group("enemies"):
            direction = -direction
    
    if not $FloorDetectorLeft.is_colliding():
        direction = 1
    elif not $FloorDetectorRight.is_colliding():
        direction = -1

func destroy():
    queue_free()

func _set_size(value: int) -> void:
    size = value
    if _is_ready:
        _update_size()

func _get_size() -> int:
    return size
