class_name WorkableSource
extends Workable

var item_pickup = preload("res://scenes/item_pickup/item_pickup.tscn")

@export var output: ItemData;
@export var available_amount: int = 1000;
var current_amount: int;


func _ready() -> void:
	can_work = true;
	current_amount = available_amount

func _on_work_finished(pos: Vector3):
	available_amount -= 1

	var item = item_pickup.instantiate() as ItemPickup
	item.item_data = output

	item.global_position = pos

	get_tree().get_root().add_child(item)

	if available_amount <= 0:
		queue_free();
