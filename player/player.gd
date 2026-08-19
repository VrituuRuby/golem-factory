extends Actor
class_name PlayerClass

const item_pickup = preload("res://world/item_pickup/item_pickup.tscn")

var SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 12;

const SENSITIVITY = 0.0025;

# HEAD BOB VARIABLES
const BOB_FREQUENCY = 2.5;
const BOB_AMPLITUDE = 0.08;
var t_bob = 0.0;

var COMMAND_STAFF_ITEM = preload("res://items/tools/command_staff.tres")
var AXE_ITEM = preload("res://items/tools/crude_axe.tres")
var STOCKPILE = preload("res://items/placeables/stockpile.tres")

@export var head: Node3D 
@export var camera: Camera3D

@onready var golem_manager: GolemManager = $GolemManager
@onready var ui: UI = $CanvasLayer/Control

var current_hovered: Node3D = null

signal display_progress(workable: Workable)
signal display_tooltip(node: Node)
signal display_interface(node: Node)
signal close_interface()

var selected_golem: GolemClass = null	

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	ui.player_inventory = inventory
	inventory.update.connect(ui._update_inventory)
	inventory.add_item(COMMAND_STAFF_ITEM)
	inventory.add_item(AXE_ITEM)
	inventory.add_item(STOCKPILE)
	ui._update_inventory()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	if Input.is_action_just_pressed("slot_1"):
		inventory.selected_slot = 0

	if Input.is_action_just_pressed("slot_2"):
		inventory.selected_slot = 1

	if Input.is_action_just_pressed("slot_3"):
		inventory.selected_slot = 2

	if Input.is_action_just_pressed("drop"):
		var slot = inventory.slots[inventory.selected_slot]
		if !slot.is_empty():
			var item_pickup = item_pickup.instantiate() as ItemPickup
			item_pickup.item_data = slot.itemData
			item_pickup.global_position = global_position + Vector3(0, 1.5, 0)
			var direction = -camera.global_transform.basis.z
			item_pickup.apply_central_impulse(direction * 5)
			get_tree().get_root().add_child(item_pickup)
			inventory.remove_selected()

	if event.is_action_pressed("scroll_up"):
		inventory.scroll_slot(1)

	if event.is_action_pressed("scroll_down"):
		inventory.scroll_slot(-1)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		on_interact()

	if(Input.is_action_just_pressed("action")):
		on_action()
		pass
	if Input.is_action_just_pressed("sub_action"):
		on_secondary_action()
	
	if Input.is_action_just_pressed("escape"):
		emit_signal("close_interface")

	if Input.is_action_just_pressed("sprint"):
		if SPEED == 5.0:
			SPEED = 10.0
		else:
			SPEED = 5.0


	var collider := ray_cast.get_collider() as Node
	if collider != current_hovered:
		if current_hovered and current_hovered.has_method("set_highlight"):
			current_hovered.set_highlight(false)
		
		current_hovered = collider
		
		if current_hovered:
			if current_hovered.has_method("set_highlight"):
				current_hovered.set_highlight(true)
			
			if current_hovered.has_method("get_tooltip_scene"):
				display_tooltip.emit(current_hovered)
			else:
				display_tooltip.emit(null)
		else:
			display_tooltip.emit(null)

	if Input.is_action_just_pressed("dismantle"):
		if collider.has_method("unmount"):
			collider.unmount()



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

func on_interact() -> void:
	if(not ray_cast.is_colliding()): return
	var collider := ray_cast.get_collider() as Node

	if collider.has_method("get_interface_scene"):
		display_interface.emit(collider)

func on_action() -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return
	if(not ray_cast.is_colliding()): return
	var collider := ray_cast.get_collider() as Node

	if collider.has_method("on_action"):
		collider.on_action(self)
		return;
	if(collider is Interactable):
		if (collider is Workable):
			collider._do_work(self)

func on_secondary_action() -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return
	if(not ray_cast.is_colliding()): return
	var collider := ray_cast.get_collider() as Node
	if collider.has_method("on_secondary_action"):
		collider.on_secondary_action(self)


func _get_progress():
	var collider := ray_cast.get_collider() as Node
	if(collider is Interactable):
		display_progress.emit(collider)
	else: 
		display_progress.emit(null)


func _handle_golem() -> void:
	pass
