extends Resource
class_name CraftingRecipe

@export var name: String = "No Name"
@export var input: Dictionary[ItemData, int] = {} 
@export var output: Dictionary[ItemData, int] = {} 

@export var required_work: int = 0;

enum Station {
	NONE,
	CRAFTING,
}

@export var station: Station = Station.NONE;

