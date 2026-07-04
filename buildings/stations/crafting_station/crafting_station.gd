extends Workable
class_name CraftingStation

const ITEM_PICKUP_SCN = preload("res://world/item_pickup/item_pickup.tscn")
const CRAFTING_INTERFACE = preload("res://buildings/stations/crafting_station/ui/interface/crafting_station_inteface.tscn")
const CRAFTING_STATION_RES = preload("res://items/placeables/placeable_crafting_station.tres")

@export var recipes: Array[CraftingRecipe] = []

@export var selected_recipe: CraftingRecipe = null

var inventory: Dictionary[ItemData, int] = {}
var max_inventory = 10

var output_quantity = 0;

func _ready():
	action_name = "Craft"

func set_recipe(recipe: CraftingRecipe) -> void:
	if selected_recipe:
		if inventory.size() > 0:
			print("Inventory not empty, cant change recipe")
			return

	selected_recipe = recipe
	update_can_craft()
	return

func add_item(item: ItemData) -> void:
	print(item)
	if (not selected_recipe):
		print("No recipe selected")
		return

	var recipe_inputs = selected_recipe.input

	if not recipe_inputs.has(item):
		print("Item not in recipe")
		return

	var total_itens: int;
	for key in recipe_inputs.keys():
		total_itens += recipe_inputs.get(key)
	
	if inventory.size() + 1 > max_inventory:
		print("Inventory full")
		return

	inventory[item] = inventory.get(item, 0) + 1
	Inventory.remove_selected()
	update_can_craft()
	
func update_can_craft():
	can_work = true
	if not selected_recipe:
		can_work = false
		return

	for item in selected_recipe.input.keys():
		var required_amount = selected_recipe.input[item]
		var current_amount = inventory.get(item, 0)

		if current_amount < required_amount:
			can_work = false
			return

func _on_work_finished(pos: Vector3, _entityPos: Vector3 = Vector3.ZERO) -> void:
	super._on_work_finished(pos)

	for key in selected_recipe.output.keys():
		var amount = selected_recipe.output.get(key)
		
		for i in range(amount):
			var item = ITEM_PICKUP_SCN.instantiate() as ItemPickup
			item.item_data = key
			item.global_position = pos

			get_tree().get_root().add_child(item)

	inventory.clear()
	update_can_craft()

func get_interface_scene() -> PackedScene:
	return CRAFTING_INTERFACE

func unmount() -> void:
	var item_pickup_instance = ITEM_PICKUP_SCN.instantiate()
	item_pickup_instance.global_position = global_position + Vector3(0, 1.5, 0)
	item_pickup_instance.item_data = CRAFTING_STATION_RES
	get_parent().add_child(item_pickup_instance)
	self.queue_free()