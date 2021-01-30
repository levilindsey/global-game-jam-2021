extends Node2D

onready var body = $KinematicBody2D

export (int) var size = 2
var velocity = Vector2.ZERO

const HORIZONTAL_ACCEL = 200.0
const VERTICAL_ACCEL = 300.0
const GRAVITY = 10.0

func _ready():
	pass
	
func _physics_process(_delta):
	velocity.x = 0

	if Input.is_action_pressed("move_left"):
		velocity.x -= HORIZONTAL_ACCEL
	if Input.is_action_pressed("move_right"):
		velocity.x += HORIZONTAL_ACCEL
	
	if Input.is_action_just_pressed("jump"):
		velocity.y -= VERTICAL_ACCEL

	# Apply gravity
	velocity.y += GRAVITY
	
	velocity = body.move_and_slide(velocity, Vector2.UP)
