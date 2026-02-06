extends Harvestable

@onready var label_3d := $Label3D as Label3D

const ITEM_PICKUP := preload("res://scenes/pickups/item_pickup.tscn")
const ITEM_DATA := preload("res://scenes/items/stone.tres")

func _ready() -> void:
	super._ready()
	label_3d.text = "%d/%d" % [current_amount, available_amount]
	print('Ore', current_amount, available_amount)

func _on_harvested(collision_position: Vector3) -> void:
	super._on_harvested(collision_position)
	label_3d.text = "%d/%d" % [current_amount, available_amount]
	var pickup := ITEM_PICKUP.instantiate() as ItemPickup
	pickup.position = collision_position 

	pickup.item_data = ITEM_DATA;
	get_parent().add_child(pickup)

