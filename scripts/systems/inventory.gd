extends Node

var items := {}

signal item_added(item: ItemData, amount: int)
signal update(items: Dictionary)

func add_item(item: ItemData, amount: int = 1) -> bool:
	items[item] = items.get(item, 0) + amount
	item_added.emit(item, amount)

	update.emit(items)
	return true

func has_item(item: ItemData, amount: int = 1) -> bool:
	return items.get(item) >= amount

func remove_item(item: ItemData, amount: int = 1) -> bool:
	if not has_item(item, amount):
		return false
	items[item] -= amount
	update.emit(items)
	return true


