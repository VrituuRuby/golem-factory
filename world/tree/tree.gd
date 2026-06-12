extends WorkableSource

@export var output_amount: int = 5;

func _do_work(work_force: int = 1, pos: Vector3 = Vector3.ZERO, entityPos: Vector3 = Vector3.ZERO) -> void:
	var selected_item =  Inventory.slots[Inventory.selected_slot]

	if selected_item is not ToolItemData: 
		print("No tool selected")
		return
	if selected_item.tool_type != ToolItemData.ToolType.AXE: 
		print("Wrong tool selected")
		return

	super._do_work(work_force, pos, entityPos)


func _on_work_finished(_pos: Vector3, _entityPos: Vector3 = Vector3.ZERO) -> void:
	for i in output_amount:
		var spawnPos = _spawn_item_height(global_position, i)
		ItemSpawner.spawn_item(output, spawnPos, Vector3.ZERO, 5.0)

	queue_free()
	

func _spawn_item_height(pos: Vector3, index: int):
	var step_height = 1;
	return Vector3(pos.x, pos.y + step_height * index, pos.z)