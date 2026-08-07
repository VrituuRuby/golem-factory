@tool
extends RigidBody3D
class_name ItemPickup

var is_hovered = false;

const MATERIAL_HIGHLIGHT := preload("res://assets/materials/mesh_highlight.tres")

const TOOLTIP_SCENE = preload("res://world/item_pickup/ItemPickupTooltip.tscn")

@onready var visual_pivot: Marker3D = $VisualPivot
@export var mesh: MeshInstance3D
@export var item_data: ItemData:
	set(value):
		item_data = value

		if is_inside_tree():
			_update_visual()

var hover_time := 0.0
var base_position := Vector3.ZERO

func _update_visual():
	mesh.scale = Vector3(item_data.mesh_scale, item_data.mesh_scale, item_data.mesh_scale)
		
	if item_data and mesh:
		mesh.mesh = item_data.mesh
		mesh.rotation_degrees = item_data.mesh_rotation
		base_position = item_data.mesh_offset
		mesh.position = base_position

func _ready() -> void:
	_update_visual()

func _process(delta):
	if Engine.is_editor_hint():
		_update_visual()
	
	hover_time += delta;

	visual_pivot.position.y = (base_position.y + sin(hover_time * 2) * 0.05)
	visual_pivot.rotation_degrees.y += 45 * delta



func launch(direction: Vector3, spawn_force: float = 5): 
	var spread := 0.3

	direction.x += randf_range(-spread, spread)
	direction.y += randf_range(0.0, spread)
	direction.z += randf_range(-spread, spread)

	apply_central_impulse(direction.normalized() * spawn_force)

func on_action(actor: Actor) -> void:
	if actor.inventory.add_item(item_data):
		queue_free()
		

func set_highlight(enabled: bool) -> void:
	if enabled:
		mesh.material_overlay = MATERIAL_HIGHLIGHT
	else: 
		mesh.material_overlay = null

func get_tooltip_scene() -> PackedScene:
	return TOOLTIP_SCENE
