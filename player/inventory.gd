extends Node

signal update()

var slots : Array[ItemData] = [
	null,
	null,
	null
]

var _selected_slot := 0

var selected_slot:
	get: return _selected_slot
	set(value):
		_selected_slot = value	
		call_update()

func call_update() -> void:
	update.emit()

func add_item(item: ItemData) -> bool:
	if slots[selected_slot] == null:
		slots[selected_slot] = item
		call_update()
		return true

	for i in slots.size():
		if slots[i] == null:
			slots[i] = item
			call_update()
			return true
	return false

func remove_item(index: int) -> void:
	slots[index] = null
	call_update()

func remove_selected() -> void:
	slots[selected_slot] = null
	call_update()

func scroll_slot(direction: int) -> void:
	if selected_slot + direction < 0:
		selected_slot = slots.size() - 1

	elif selected_slot + direction >= slots.size():
		selected_slot = 0
	else:
		selected_slot += direction
	call_update()

func has_item(item: ItemData, amount: int = 1) -> bool:
	var count := 0
	
	for slot in slots:
		if slot == item:
			count += 1
	
	return count >= amount

func remove_item_anywhere(item: ItemData, amount: int = 1) -> void:
	if not has_item(item, amount):
		return

	var remaining := amount

	for index in range(slots.size()):
		if slots[index] == item:
			remove_item(index)
			remaining -= 1

			if remaining <= 0:
				break
