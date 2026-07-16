extends Node
class_name BuildSystem

@export var hand_target: Marker3D 
@export var blueprint_scene: PackedScene

var blueprint: Blueprint = null;

var desired_rotation := Vector3.ZERO

const GRID_SIZE = .25

func _ready() -> void:
	Inventory.update.connect(func ():
		var selected_item = Inventory.slots[Inventory.selected_slot].itemData
		if selected_item is PlaceableItemData:
			_on_select_blueprint(selected_item)
		else:
			if blueprint:
				blueprint.queue_free()
				blueprint = null
		)

func snap_to_grid(pos: Vector3) -> Vector3:
	var x = round(pos.x / GRID_SIZE) * GRID_SIZE
	var y = round(pos.y / GRID_SIZE) * GRID_SIZE
	var z = round(pos.z / GRID_SIZE) * GRID_SIZE
	return Vector3(x, y, z)

func _handle_input():
	if not blueprint: return

	if Input.is_action_just_pressed("rotate_left"):
		desired_rotation.y += deg_to_rad(90)
	elif Input.is_action_just_pressed("rotate_right"):
		desired_rotation.y -= deg_to_rad(90)

	if Input.is_action_just_pressed("action") && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if blueprint.place():
			blueprint.rotation = desired_rotation
			blueprint = null;
			Inventory.remove_selected()

func _process(delta: float) -> void:
	if blueprint == null: return

	var snap_pos: Vector3 = snap_to_grid(hand_target.global_position)
	blueprint.global_position = lerp(blueprint.global_position, snap_pos, 20 * delta)

	blueprint.rotation.y = lerp_angle(blueprint.rotation.y, desired_rotation.y, 10 * delta)

	_handle_input()


func _on_select_blueprint(placeable_data: PlaceableItemData) -> void:
	if not (blueprint == null):
		blueprint.queue_free()
		blueprint = null

	blueprint = blueprint_scene.instantiate() as Blueprint
	blueprint.build_data = placeable_data
	blueprint.global_position = get_parent().global_position
	get_parent().get_parent().add_child(blueprint)
