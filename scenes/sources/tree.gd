extends Harvestable

const ITEM_PICKUP := preload("res://scenes/pickups/item_pickup.tscn")
const ITEM_DATA := preload("res://scenes/items/wood.tres")

func _on_harvested(collision_position: Vector3) -> void:
	var pickup := ITEM_PICKUP.instantiate() as ItemPickup
	pickup.position = collision_position 

	pickup.item_data = ITEM_DATA;
	get_parent().add_child(pickup)