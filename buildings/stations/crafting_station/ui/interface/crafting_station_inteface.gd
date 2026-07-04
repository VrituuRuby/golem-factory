extends Control

@onready var recipe_list: VBoxContainer = $Panel/VBoxContainer
@onready var description_text: RichTextLabel = $Panel/Panel/RichTextLabel
@onready var current_itens_list: RichTextLabel = $RichTextLabel
@onready var set_recipe_btn: Button = $Panel/Button

var recipes: Array[CraftingRecipe] = []
var selected_recipe: CraftingRecipe = null
var display_recipe: CraftingRecipe = null
var crafting_station: CraftingStation = null

func _ready() -> void:
	set_recipe_btn.connect("pressed", func (): 
		if display_recipe:
			_set_selected_recipe(display_recipe)
			self.get_parent()._close_interface()
	)

func setup(node: Node) -> void:
	if node is not CraftingStation:
		return
	
	crafting_station = node

	recipes = node.recipes
	update_recipe_list()

	if node.selected_recipe:
		_set_selected_recipe(node.selected_recipe)
		_set_display_recipe(node.selected_recipe)
		update_current_itens()

func _set_display_recipe(recipe: CraftingRecipe) -> void:
	print(recipe)
	display_recipe = recipe

	var ingredients_text = "Required Items:"

	var ingredients = recipe.input.keys()
	for item in ingredients:
		var amount = recipe.input.get(item)
		ingredients_text += "\n" + item.name + " x " + str(amount)
	
	description_text.text = recipe.description + "\n\n" + ingredients_text

func _set_selected_recipe(recipe: CraftingRecipe) -> void:
	selected_recipe = recipe
	crafting_station.set_recipe(recipe)

func update_recipe_list() -> void:
	print(recipe_list)
	for child in recipe_list.get_children():
		child.queue_free()
	
	for recipe in recipes:
		var recipe_option = Button.new()
		recipe_option.text = recipe.name
		recipe_list.add_child(recipe_option)

		recipe_option.connect("pressed", func(): _set_display_recipe(recipe))

func update_current_itens() -> void:
	current_itens_list.text = ""
	for item in crafting_station.inventory.keys():
		var amount = crafting_station.inventory.get(item)
		current_itens_list.text += item.name + " x " + str(amount) + "\n"