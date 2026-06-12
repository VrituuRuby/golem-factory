extends RigidBody3D

const MATERIAL_HIGHLIGHT := preload("res://assets/materials/mesh_highlight.tres")

@export var mesh: MeshInstance3D

var item_data: ToolItemData;

func pickup() -> void:
	print(item_data)
	if Inventory.add_item(item_data):
		queue_free()

func set_highlight(enabled: bool) -> void:
	if enabled:
		mesh.material_overlay = MATERIAL_HIGHLIGHT
	else: 
		mesh.material_overlay = null
