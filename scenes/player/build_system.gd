extends Node
class_name BuildSystem

@export var hand_target: Marker3D 
@export var blueprint_scene: PackedScene

var blueprint: Blueprint = null;

var desired_rotation := Vector3.ZERO

const GRID_SIZE = .25

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
			for item in blueprint.build_data.input.keys():
				var amount = blueprint.build_data.input[item]
				Inventory.remove_item(item, amount)
			blueprint = null;

func _process(_delta: float) -> void:
	if blueprint == null: return

	var snap_pos: Vector3 = snap_to_grid(hand_target.global_position)
	blueprint.global_position = lerp(blueprint.global_position, snap_pos, 0.2)

	blueprint.rotation.y = lerp_angle(blueprint.rotation.y, desired_rotation.y, 0.5)

	_handle_input()


func _on_control_select_blueprint(build_data: BuildData) -> void:
	if not (blueprint == null):
		blueprint.queue_free()
		blueprint = null

	blueprint = blueprint_scene.instantiate() as Blueprint
	blueprint.build_data = build_data
	blueprint.global_position = get_parent().global_position
	get_parent().get_parent().add_child(blueprint)
