@tool
extends RigidBody3D
class_name ItemPickup

var velocity := Vector3.ZERO
var spawn_force = 5

var is_hovered = false;

const MATERIAL_HIGHLIGHT := preload("res://assets/materials/mesh_highlight.tres")

@export var mesh: MeshInstance3D

@export var item_data: ItemData:
	set(value):
		item_data = value
		_update_visual()

func _update_visual():
	if not is_inside_tree():
		return
		
	if item_data and mesh:
		mesh.mesh = item_data.mesh

func _ready() -> void:
	_update_visual()


func launch(direction: Vector3):
	var spread := 0.3

	direction.x += randf_range(-spread, spread)
	direction.y += randf_range(0.0, spread)
	direction.z += randf_range(-spread, spread)

	apply_central_impulse(direction.normalized() * spawn_force)

func pickup() -> void:
	if Inventory.add_item(item_data):
		queue_free()

func set_highlight(enabled: bool) -> void:
	if enabled:
		mesh.material_overlay = MATERIAL_HIGHLIGHT
	else: 
		mesh.material_overlay = null
