extends Node
class_name Inventory

signal update()

@export var max_slot_count := 1

var slots : Array[InventorySlot] = []

var _selected_slot := 0

var selected_slot: int:
	get: 
		return _selected_slot
	set(value):
		_selected_slot = value	
		update.emit()


func get_selected_slot() -> InventorySlot:
	return slots[selected_slot]

func _ready():
	slots.clear()

	for i in max_slot_count:
		slots.append(InventorySlot.new())

func add_item(item: ItemData) -> bool:
	if (item.stackable):
		for slot in slots: 
			if slot.itemData == item and slot.amount < item.max_stack:
				slot.amount += 1
				update.emit()
				return true

	if slots[selected_slot].is_empty():
		slots[selected_slot].itemData = item
		slots[selected_slot].amount = 1
		update.emit()
		return true
	
	for slot in slots:
		if slot.is_empty():
			slot.itemData = item
			slot.amount = 1
			update.emit()
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
	update.emit()

func remove_selected(amount: int = 1) -> void:
	remove_item(selected_slot, amount)

func scroll_slot(direction: int) -> void:
	if selected_slot + direction < 0:
		selected_slot = slots.size() - 1

	elif selected_slot + direction >= slots.size():
		selected_slot = 0
	else:
		selected_slot += direction
	update.emit()

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
