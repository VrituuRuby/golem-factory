extends Node

signal update()

var slots : Array[InventorySlot] = [
	InventorySlot.new(),
	InventorySlot.new(),
	InventorySlot.new(),
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
	if (item.stackable):
		for slot in slots: 
			if slot.itemData == item and slot.amount < item.max_stack:
				slot.amount += 1
				call_update()
				return true

	if slots[selected_slot].is_empty():
		slots[selected_slot].itemData = item
		slots[selected_slot].amount = 1
		call_update()
		return true
	
	for slot in slots:
		if slot.is_empty():
			slot.itemData = item
			slot.amount = 1
			call_update()
			return true
	return false

func remove_item(index: int, amount: int = 1) -> void:
	print("remove_item", index, amount)
	var slot := slots[index]
	
	print("slot", slot)
	if slot.is_empty():
		return

	slot.amount -= amount
	if slot.amount <= 0:
		slot.itemData = null
		slot.amount = 0
	call_update()

func remove_selected(amount: int = 1) -> void:
	remove_item(selected_slot, amount)

func scroll_slot(direction: int) -> void:
	if selected_slot + direction < 0:
		selected_slot = slots.size() - 1

	elif selected_slot + direction >= slots.size():
		selected_slot = 0
	else:
		selected_slot += direction
	call_update()

func has_item(item: ItemData, amount: int = 1) -> bool:
	var total := 0
	for slot in slots:
		if slot.itemData == item and slot.amount >= amount:
			total += slot.amount
	return total >= amount

func remove_item_anywhere(item: ItemData, amount: int = 1) -> void:
	var remaining := amount

	for index in range(slots.size()):
		if slots[index].itemData == item:
			print("remove_item_anywhere", index, amount)
			remove_item(index)
			remaining -= 1

			if remaining <= 0:
				break
