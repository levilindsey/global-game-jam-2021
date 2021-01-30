extends KinematicBody2D
class_name Player

const Bit := preload("res://scenes/bit.tscn")

export (int) var size = 2
var velocity = Vector2.ZERO

const HORIZONTAL_ACCEL = 200.0
const VERTICAL_ACCEL = 300.0
const GRAVITY = 10.0

const DEFAULT_BIT_SIZE = 1


func _ready():
	pass

func _physics_process(_delta):
	velocity.x = 0

	if Input.is_action_pressed("move_left"):
		velocity.x -= HORIZONTAL_ACCEL
	if Input.is_action_pressed("move_right"):
		velocity.x += HORIZONTAL_ACCEL
	
	if Input.is_action_just_pressed("jump") and size > 1:
		velocity.y = -VERTICAL_ACCEL
		_emit()
	
	# Apply gravity
	velocity.y += GRAVITY
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	_update_size()

func _emit():
	var bit_size = DEFAULT_BIT_SIZE
	size -= bit_size
	
	var level = get_tree().get_nodes_in_group('levels')[0]
	
	var bit = Bit.instance()
	level.add_child(bit)
	bit.size = bit_size
	bit.linear_velocity = -velocity * 0.5
	bit.position = global_position - (_get_radius() + bit.get_radius() + 0.1) * velocity.normalized()

func _get_radius():
	return Constants.SIZE_SCALE * sqrt(size)

func _update_size():
	$CollisionShape2D.shape.radius = _get_radius()
	$Area2D/CollisionShape2D.shape.radius = _get_radius()

func _on_Area2D_body_entered(body):
	if body.is_in_group("bits"):
		size += body.size
		body.destroy()
