extends ItemData
class_name ToolItemData

enum ToolType {
	AXE,
	PICKAXE,
	STAFF
}

@export var tool_type: ToolType = ToolType.AXE;