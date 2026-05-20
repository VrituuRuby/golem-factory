extends Node

const WOOD := preload("res://scenes/items/wood.tres")
const STONE := preload("res://scenes/items/stone.tres")

var items : Dictionary[ItemData, int] = {
	WOOD: 100,
	STONE: 100,
}

var selected_item: ItemData = WOOD

func _ready() -> void:
		update.emit(items, selected_item)


signal item_added(item: ItemData, amount: int)
signal update(items: Dictionary, selected_item: ItemData)

func add_item(item: ItemData, amount: int = 1) -> bool:
	items[item] = items.get(item, 0) + amount
	item_added.emit(item, amount)

	selected_item = item
	update.emit(items, selected_item)
	return true

func has_item(item: ItemData, amount: int = 1) -> bool:
	return items.get(item, 0) >= amount

func remove_item(item: ItemData, amount: int = 1) -> bool:
	if not has_item(item, amount):
		return false
	items[item] -= amount
	update.emit(items, selected_item)
	return true

func get_all_items() -> Dictionary:
	return items

func set_selected_by_index(index: int):
	var keys = items.keys()

	if keys.is_empty(): return

	index = clamp(index, 0, keys.size() - 1)

	selected_item = keys[index]
	update.emit(items, selected_item)

func scroll_selected(direction: int):
	var keys = items.keys()

	if keys.is_empty():
		return

	var current_index = keys.find(selected_item)

	if current_index == -1:
		current_index = 0

	current_index += direction

	if current_index >= keys.size():
		current_index = 0

	if current_index < 0:
		current_index = keys.size() - 1

	selected_item = keys[current_index]

	update.emit(items, selected_item)
