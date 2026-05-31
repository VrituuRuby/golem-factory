extends WorkableSource

@export var output_amount: int = 5;

func _on_work_finished(_pos: Vector3, _entityPos: Vector3 = Vector3.ZERO) -> void:
	for i in output_amount:
		var item = item_pickup.instantiate() as ItemPickup
		item.item_data = output

		item.spawn_force = 1
		item.global_position = _spawn_item_height(global_position, i)
		var randomDir = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
		item.launch(randomDir)

		get_parent().add_child(item)

	queue_free()
	

func _spawn_item_height(pos: Vector3, index: int):
	var step_height = 1;
	return Vector3(pos.x, pos.y + step_height * index, pos.z)