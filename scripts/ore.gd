extends Harvestable

var itemScene := preload("res://scenes/item_pickup.tscn")

func _on_harvested(collision_position: Vector3) -> void:
	var pickupItemInstance := itemScene.instantiate()
	pickupItemInstance.position = collision_position 
	get_parent().add_child(pickupItemInstance)