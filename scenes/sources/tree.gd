extends WorkableSource

@export var output_amount: int = 5;

func _on_work_finished(_pos: Vector3):
	for i in output_amount:
		var item = item_pickup.instantiate() as ItemPickup
		item.item_data = output

		item.spawn_force = 1
		item.global_position = _spawn_item_height(global_position, i)

		get_tree().get_root().add_child(item)

	queue_free()
	pass
	

func _spawn_item_height(pos: Vector3, index: int):
	var step_heigth = 0.5;

	return Vector3(pos.x, pos.y + step_heigth * index, pos.z)