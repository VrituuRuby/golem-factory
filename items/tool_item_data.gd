extends ItemData
class_name ToolItemData

enum ToolType {
	AXE,
	PICKAXE,
}

@export var durability: int = 100;
@export var tool_type: ToolType = ToolType.AXE;