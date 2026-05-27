extends CharacterBody3D
class_name PlayerClass

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 12;

const SENSITIVITY = 0.0025;

# HEAD BOB VARIABLES
const BOB_FREQUENCY = 2.5;
const BOB_AMPLITUDE = 0.08;
var t_bob = 0.0;

@export var head: Node3D 
@export var camera: Camera3D
@export var ray_cast: RayCast3D

@onready var golem_manager: GolemManager = $GolemManager

signal display_progress(workable: Workable)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	if Input.is_action_just_pressed("slot_1"):
		Inventory.set_selected_by_index(0)

	if Input.is_action_just_pressed("slot_2"):
		Inventory.set_selected_by_index(1)

	if event.is_action_pressed("scroll_up"):
		Inventory.scroll_selected(1)

	if event.is_action_pressed("scroll_down"):
		Inventory.scroll_selected(-1)

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("action")):
		_interact()
		pass
	if Input.is_action_just_pressed("sub_action"):
		_interact_secondary()

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
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
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
	_get_progress()


func _headbob(t: float) -> Vector3:
	var pos := Vector3.ZERO
	pos.y = sin(t * BOB_FREQUENCY) * BOB_AMPLITUDE
	pos.x = cos(t * BOB_FREQUENCY / 2) * BOB_AMPLITUDE
	return pos

func _interact() -> void:
	if(not ray_cast.is_colliding()): return
	var collider := ray_cast.get_collider() as Node
	if(collider is Interactable):
		if (collider is Workable):
			var collision_position := ray_cast.get_collision_point()
			collider._do_work(1,collision_position)
		if (collider is Stockpile):
			var selected_item := Inventory.selected_item
			if selected_item:
				collider.add_item(selected_item)

func _interact_secondary() -> void:
	if(not ray_cast.is_colliding()): return
	var collider := ray_cast.get_collider() as Node
	if collider is Interactable:
		if collider is CraftingStation:
			collider.add_item(Inventory.selected_item)
		if collider is Stockpile and not golem_manager.selected_golem:
			collider.remove_item()
	_handle_golem()

func _get_progress():
	var collider := ray_cast.get_collider() as Node
	if(collider is Interactable):
		display_progress.emit(collider)
	else: 
		display_progress.emit(null)


func _handle_golem() -> void:
	if(not ray_cast.is_colliding()): return

	var collider := ray_cast.get_collider() as Node
	print(collider)
	if golem_manager.selected_golem == null: 
		if(collider is GolemClass):
			golem_manager.set_golem(collider as GolemClass)
	else:
		if(collider is Workable):
			golem_manager.assign_workable(collider as Workable)
		if (collider is Stockpile):
			golem_manager.selected_golem.assign_stockpile(collider as Stockpile)
			golem_manager.selected_golem = null
