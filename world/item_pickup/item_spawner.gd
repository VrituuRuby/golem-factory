extends Node

var scene = preload("res://world/item_pickup/item_pickup.tscn")

func spawn_item(item_data: ItemData, pos: Vector3, launch_dir: Vector3 = Vector3.ZERO, spawn_force: float = 5) -> void:
	var item_pickup = scene.instantiate()

	item_pickup.item_data = item_data
	item_pickup.global_position = pos

	get_tree().get_root().add_child(item_pickup)
