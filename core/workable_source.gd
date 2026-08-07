class_name WorkableSource
extends Workable

var item_pickup = preload("res://world/item_pickup/item_pickup.tscn")

@export var output: ItemData;
@export var available_amount: int = 1000;
var current_amount: int;

func _ready() -> void:
	can_work = true;
	current_amount = available_amount

func _on_work_finished(actor: Actor = null) -> void:
	super._on_work_finished(actor)
	available_amount -= 1

	var entity_pos = Vector3.ZERO

	if actor:
		entity_pos = actor.global_position

	var spawnDir = entity_pos - actor.global_position
	var spawn_position = actor.ray_cast.get_collision_point()
	ItemSpawner.spawn_item(output, spawn_position, spawnDir, 1.0)

	if available_amount <= 0:
		queue_free();
