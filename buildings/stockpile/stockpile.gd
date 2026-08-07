extends Interactable
class_name Stockpile

var stock_item: ItemData;
var quantity: int = 0;

func _ready() -> void:
	action_name = "Chose Item"

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

func add_item(actor) -> void:
	var selected_slot = actor.inventory.selected_slot
	var item = actor.inventory.slots[selected_slot].itemData

	if not item: return

	if not stock_item: 
		set_stock_item(item)

	if item != stock_item: return

	actor.inventory.remove_item(selected_slot)
	increase_quantity()

func on_action(actor) -> void:
	var selected_slot = actor.inventory.selected_slot
	add_item(actor.inventory.slots[selected_slot].itemData)

func on_secondary_action(actor) -> void:
	if not stock_item: return

	if quantity <= 0: return

	actor.inventory.add_item(stock_item)
	decrease_quantity()
