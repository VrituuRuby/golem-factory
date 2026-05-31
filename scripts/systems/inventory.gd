extends Node

signal update()

var slots : Array[ItemData] = [
	null,
	null,
	null
]

var selected_slot := 0:
	set(value):
		selected_slot = value
		update.emit()

func add_item(item: ItemData) -> bool:
	if slots[selected_slot] == null:
		slots[selected_slot] = item
		update.emit()
		return true

	for i in slots.size():
		if slots[i] == null:
			slots[i] = item
			update.emit()
			return true
	return false

func remove_item(index: int) -> void:
	slots[index] = null
	update.emit()

func remove_selected() -> void:
	slots[selected_slot] = null
	update.emit()

func scroll_slot(direction: int) -> void:
	selected_slot += direction
	if selected_slot < 0:
		selected_slot = slots.size() - 1

	if selected_slot >= slots.size():
		selected_slot = 0
	update.emit()
