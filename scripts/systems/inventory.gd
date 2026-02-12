extends Node

const WOOD := preload("res://scenes/items/wood.tres")
const STONE := preload("res://scenes/items/stone.tres")


var items : Dictionary[ItemData, int] = {
	WOOD: 100,
	STONE: 100,
}

func _ready() -> void:
	update.emit(items)

signal item_added(item: ItemData, amount: int)
signal update(items: Dictionary)

func add_item(item: ItemData, amount: int = 1) -> bool:
	items[item] = items.get(item, 0) + amount
	item_added.emit(item, amount)

	update.emit(items)
	return true

func has_item(item: ItemData, amount: int = 1) -> bool:
	return items.get(item, 0) >= amount

func remove_item(item: ItemData, amount: int = 1) -> bool:
	if not has_item(item, amount):
		return false
	items[item] -= amount
	update.emit(items)
	return true
