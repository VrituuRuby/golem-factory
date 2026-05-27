extends Workable
class_name CraftingStation

var item_pickup = preload("res://scenes/item_pickup/item_pickup.tscn")

@export var selected_recipe: CraftingRecipe = null

var inventory: Dictionary[ItemData, int] = {}

func _ready():
	action_name = "Craft"

func add_item(item: ItemData) -> void:
	print(item)
	if (not selected_recipe): 
		print("No recipe selected")
		return

	var recipe_inputs = selected_recipe.inputs

	if not recipe_inputs.has(item):
		print("Item not in recipe")
		return


	var required_amount = recipe_inputs[item]
	if inventory.get(item, 0) >= required_amount:
		print("Already have enough")
		return
	inventory[item] = inventory.get(item, 0) + 1
	Inventory.remove_item(item, 1)
	update_can_craft()
	
func update_can_craft():
	can_work = true
	if not selected_recipe: 
		can_work = false
		return

	for item in selected_recipe.inputs.keys():
		var required_amount = selected_recipe.inputs[item]
		var current_amount = inventory.get(item, 0)

		if current_amount < required_amount:
			can_work = false
			return

func _on_work_finished(pos: Vector3) -> void:
	super._on_work_finished(pos)

	for key in selected_recipe.outputs.keys():
		var amount = selected_recipe.outputs.get(key)
		
		for i in range(amount):
			var item = item_pickup.instantiate() as ItemPickup
			item.item_data = key
			item.global_position = pos

			get_tree().get_root().add_child(item)

	inventory.clear()
	update_can_craft()


