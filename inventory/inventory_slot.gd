extends Resource
class_name InventorySlot

@export var itemData: ItemData = null
@export var amount: int = 0

func is_empty() -> bool:
	return itemData == null