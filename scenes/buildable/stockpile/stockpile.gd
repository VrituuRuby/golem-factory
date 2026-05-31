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

func add_item(item: ItemData) -> void:
	if not item: return

	if not stock_item: 
		set_stock_item(item)

	if item != stock_item: return

	Inventory.remove_item(Inventory.selected_slot)
	increase_quantity()

func remove_item() -> void:
	if not stock_item: return

	if quantity <= 0: return

	Inventory.add_item(stock_item)
	decrease_quantity()