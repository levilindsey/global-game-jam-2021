extends Node2D

const Bit := preload("res://scenes/bit.tscn")

onready var body = $KinematicBody2D

export (int) var size = 2
var velocity = Vector2.ZERO

const DEFAULT_RADIUS = 10.0
const HORIZONTAL_ACCEL = 200.0
const VERTICAL_ACCEL = 300.0
const GRAVITY = 10.0


func _ready():
    pass

func _physics_process(_delta):
    _update_size()
    
    velocity.x = 0

    if Input.is_action_pressed("move_left"):
        velocity.x -= HORIZONTAL_ACCEL
    if Input.is_action_pressed("move_right"):
        velocity.x += HORIZONTAL_ACCEL
    
    if Input.is_action_just_pressed("jump") and size > 1:
        velocity.y -= VERTICAL_ACCEL
        size -= 1
    
    if Input.is_action_just_pressed("embiggen"):
        size += 1
    
    # Apply gravity
    velocity.y += GRAVITY
    
    velocity = body.move_and_slide(velocity, Vector2.UP)
    
    for i in body.get_slide_count():
        var collision = body.get_slide_collision(i)
        if collision.collider.is_in_group("bits"):
            size += collision.collider.size
            collision.collider.destroy()

func _update_size():
    var radius = DEFAULT_RADIUS * sqrt(size)
    $KinematicBody2D/CollisionShape2D.shape.radius = radius
    $KinematicBody2D/Area2D/CollisionShape2D.shape.radius = radius

func _on_Area2D_body_entered(body):
    if body.is_in_group("bits"):
        size += body.size
        body.destroy()
