class_name WorkableSource
extends Workable

var item_pickup = preload("res://world/item_pickup/item_pickup.tscn")

@export var output: ItemData;
@export var available_amount: int = 1000;
var current_amount: int;

func _ready() -> void:
	can_work = true;
	current_amount = available_amount

func _on_work_finished(pos: Vector3, entityPos: Vector3 = Vector3.ZERO) -> void:
	super._on_work_finished(pos)
	available_amount -= 1

	var spawnDir = entityPos - pos
	ItemSpawner.spawn_item(output, pos, spawnDir, 1.0)

	if available_amount <= 0:
		queue_free();
