extends Interactable
class_name Stockpile

var COLLECT_NEARBY_TASK =preload("res://golemns/tasks/collect_nearby_task.gd")

var stock_item: ItemData;
var quantity: int = 0;
@onready var detector_area: Area3D = $DetectorArea

var available_pickups: Array[ItemPickup] = []

signal available_pickups_update(available_pickups: Array[ItemPickup])

func _ready() -> void:
	action_name = "Chose Item"
	detector_area.body_entered.connect(func (body):
		print("body entered")
		if body is not ItemPickup: return
		if body.item_data != stock_item: return
		available_pickups.append(body)
		available_pickups_update.emit(available_pickups)
	)

	detector_area.body_exited.connect(func (body):
		print("body exited")
		if body is not ItemPickup: return
		if body.item_data != stock_item: return
		available_pickups.erase(body)
		available_pickups_update.emit(available_pickups)
	)

func set_stock_item(item: ItemData) -> void:
	stock_item = item
	action_name = "Stock %s (%d)" % [stock_item.name, quantity]

func increase_quantity() -> void:
	quantity += 1
	action_name = "Stock %s (%d)" % [stock_item.name, quantity]

func decrease_quantity() -> void:
	quantity -= 1
	action_name = "Stock %s (%d)" % [stock_item.name, quantity]

	if quantity <= 0:
		quantity = 0
		action_name = "Chose Item"
		stock_item = null
	else:
		action_name = "Stock %s (%d)" % [stock_item.name, quantity]

func add_item(actor: Actor) -> void:
	var selected_slot = actor.inventory.selected_slot
	var item = actor.inventory.slots[selected_slot].itemData

	if not item: return

	if not stock_item: 
		set_stock_item(item)

	if item != stock_item: return

	actor.inventory.remove_item(selected_slot)
	increase_quantity()

func on_action(actor: Actor) -> void:
	add_item(actor)

func on_secondary_action(actor: Actor) -> void:
	if actor is PlayerClass:
		var selected_item = actor.inventory.slots[actor.inventory.selected_slot].itemData
		if selected_item is not ToolItemData: return
		if selected_item.tool_type != ToolItemData.ToolType.STAFF: return
		if not actor.selected_golem: return
		
		var task = COLLECT_NEARBY_TASK.new(self, actor.selected_golem)
		actor.selected_golem.assigned_task = task
		print("Assigned Collect task to golem")
		actor.selected_golem = null
		return

	if not stock_item: return

	if quantity <= 0: return
	actor.inventory.add_item(stock_item)
	decrease_quantity()
