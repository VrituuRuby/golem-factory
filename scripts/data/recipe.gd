extends Resource
class_name CraftingRecipe

@export var inputs: Dictionary[ItemData, int] = {} 
@export var outputs: Dictionary[ItemData, int] = {} 

@export var required_work: int = 10;

