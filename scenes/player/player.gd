extends CharacterBody3D
class_name PlayerClass

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 12;

const SENSITIVITY = 0.005;

# HEAD BOB VARIABLES
const BOB_FREQUENCY = 2.5;
const BOB_AMPLITUDE = 0.08;
var t_bob = 0.0;

@export var head: Node3D 
@export var camera: Camera3D
@export var ray_cast: RayCast3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-45), deg_to_rad(60))

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("action")):
		_do_work()
		pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = lerp(velocity.x, direction.x, delta * 10)
			velocity.z = lerp(velocity.z, direction.z, delta  * 10)
	else: 
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 3)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 3)

	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	move_and_slide()


func _headbob(t: float) -> Vector3:
	var pos := Vector3.ZERO
	pos.y = sin(t * BOB_FREQUENCY) * BOB_AMPLITUDE
	pos.x = cos(t * BOB_FREQUENCY / 2) * BOB_AMPLITUDE
	return pos

func _do_work() -> void:
	if(not ray_cast.is_colliding()): return
	var collider := ray_cast.get_collider() as Node
	if(collider is Workable):
		var collision_position := ray_cast.get_collision_point()
		collider._do_work(1,collision_position)
