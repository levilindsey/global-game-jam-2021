extends KinematicBody2D
class_name Enemy

export var size := 3
export var spiky = false

var speed := 100.0
var velocity = Vector2.ZERO
var direction = 1

const GRAVITY = 10.0

func _ready():
    if spiky:
        $CollisionShape2D.shape = RectangleShape2D.new()
    else:
        $CollisionShape2D.shape = CircleShape2D.new()

func _physics_process(_delta):
    _update_size()
    _update_direction()
    
    if not $FloorDetectorLeft.is_colliding() and not $FloorDetectorRight.is_colliding():
        velocity.y += GRAVITY
        velocity.x = 0
    else:
        velocity.x = speed * direction
        velocity.y = 0

    velocity = move_and_slide(velocity, Vector2.UP)

func get_radius():
    return Constants.SIZE_SCALE * sqrt(size)

func _update_size():
    var radius = get_radius()
    if spiky:
        $CollisionShape2D.shape.extents = Vector2(radius, radius)
    else:
        $CollisionShape2D.shape.radius = radius
    $FloorDetectorLeft.position = Vector2(-radius, radius)
    $FloorDetectorRight.position = Vector2(radius, radius)

func _update_direction():
    for i in get_slide_count():
        var collision = get_slide_collision(i)
        if collision.collider.is_in_group("enemies"):
            direction = -direction
    
    if not $FloorDetectorLeft.is_colliding():
        direction = 1
    elif not $FloorDetectorRight.is_colliding():
        direction = -1

func destroy():
    queue_free()
