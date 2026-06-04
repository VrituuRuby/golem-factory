extends Control

const LABEL = preload("res://player/ui/resourse_label.tscn")


@onready var crafting_panel: Panel = $CraftingPanel
@onready var recipe_list: VBoxContainer = $CraftingPanel/RecipesList
@onready var recipe_option_scene: PackedScene = preload("res://player/ui/recipe_option.tscn")

@export var recipes: Array[CraftingRecipe]  

@onready var _action_label: Label = $ActionTextLabel
@onready var _progress_bar: TextureProgressBar = $TextureProgressBar

@onready var inventory_slots: BoxContainer = $InventorySlots

var is_crafting_panel_open := false

func _ready() -> void:
	Inventory.update.connect(_update_inventory)

	update_crafting_panel()
	_update_inventory()

func update_crafting_panel() -> void:
	for child in recipe_list.get_children():
		child.queue_free()

	for recipe in recipes:
		var recipe_option = recipe_option_scene.instantiate()
		recipe_option.setup(recipe)

		recipe_option.craft_pressed.connect(handle_craft)

		recipe_list.add_child(recipe_option)

func handle_craft(recipe: CraftingRecipe) -> void:
	_toggle_build_panel()
	for item in recipe.input.keys():
		var amount = recipe.input[item]
		Inventory.remove_item_anywhere(item, amount)

	# TODO: This is only working if recipe returns a single item, which is what manually crafting does rn. 
	var output = recipe.output.keys()[0] 
	Inventory.add_item(output)
	update_crafting_panel()

func _update_inventory() -> void:
	for child in inventory_slots.get_children():
		child.queue_free()

	for i in range(Inventory.slots.size()):
		var item = Inventory.slots[i]
		var label: Label = LABEL.instantiate()

		label.label_settings = label.label_settings.duplicate()
		label.label_settings.outline_size = 0

		if item:
			label.text = "[%s]" % item.name
		else:
			label.text = '[Empty]'
			label.label_settings.font_color = Color(1, 1, 1, .5)
		if Inventory.selected_slot == i:
			label.label_settings.font_color = Color.YELLOW

		inventory_slots.add_child(label)
	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_build_panel"):
		_toggle_build_panel()

func _toggle_build_panel() -> void:
	is_crafting_panel_open = not is_crafting_panel_open
	if is_crafting_panel_open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		crafting_panel.visible = true;
		update_crafting_panel()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		crafting_panel.visible = false;


func _on_character_body_3d_display_progress(interactable: Interactable) -> void:
	if interactable == null:
		_progress_bar.visible = false
		_progress_bar.value = 0
		_action_label.text = ''
		_action_label.visible = false
	else:
		_action_label.text = interactable.action_name
		_action_label.visible = true

	if interactable is Workable:
		if interactable.can_work:
			_progress_bar.visible = true
			var progress = float(interactable.work_counter) / float(interactable.required_work) * 100.0
			_progress_bar.value = progress
