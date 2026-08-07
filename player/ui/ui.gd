extends Control
class_name UI

const LABEL = preload("res://player/ui/resourse_label.tscn")


@onready var crafting_panel: Panel = $CraftingPanel
@onready var recipe_list: VBoxContainer = $CraftingPanel/RecipesList
@onready var recipe_option_scene: PackedScene = preload("res://player/ui/recipe_option.tscn")

@export var recipes: Array[CraftingRecipe]  

@onready var _action_label: Label = $ActionTextLabel
@onready var _progress_bar: TextureProgressBar = $TextureProgressBar

@onready var inventory_slots: BoxContainer = $InventorySlots

var is_crafting_panel_open := false

@export var tooltip_pivot: Control
@export var player: PlayerClass
var current_tooltip: Node = null
var current_interface: Node = null
var player_inventory: Inventory


func _ready() -> void:
	player_inventory = player.inventory
	update_crafting_panel()
	_update_inventory()

func close_interface() -> void:
	if is_crafting_panel_open:
		_toggle_build_panel()
	if current_interface:
		current_interface.queue_free()
		current_interface = null
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func update_crafting_panel() -> void:
	for child in recipe_list.get_children():
		child.queue_free()

	for recipe in recipes:
		var recipe_option = recipe_option_scene.instantiate()
		recipe_option.setup(recipe, player_inventory)

		recipe_option.craft_pressed.connect(handle_craft)

		recipe_list.add_child(recipe_option)

func handle_craft(recipe: CraftingRecipe) -> void:
	_toggle_build_panel()
	for item in recipe.input.keys():
		var amount = recipe.input[item]
		player_inventory.remove_item_anywhere(item, amount)

	# TODO: This is only working if recipe returns a single item, which is what manually crafting does rn. 
	var output = recipe.output.keys()[0] 
	player_inventory.add_item(output)
	update_crafting_panel()

func _update_inventory() -> void:
	for child in inventory_slots.get_children():
		child.queue_free()

	for i in range(player_inventory.slots.size()):
		var slot = player_inventory.slots[i]
		var label: Label = LABEL.instantiate()

		label.label_settings = label.label_settings.duplicate()
		label.label_settings.outline_size = 0

		if slot.itemData:
			label.text = "[%dx %s]" % [slot.amount, slot.itemData.name]
		else:
			label.text = '[Empty]'
			label.label_settings.font_color = Color(1, 1, 1, .5)
		if player_inventory.selected_slot == i:
			label.label_settings.font_color = Color.YELLOW

		inventory_slots.add_child(label)
	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_build_panel"):
		_toggle_build_panel()

func _toggle_build_panel() -> void:
	if current_interface: return
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

func _on_body_3d_display_tooltip(node: Node) -> void:
	if current_tooltip:
		current_tooltip.queue_free()
		current_tooltip = null
	
	if node == null:
		return
	
	var scene = node.get_tooltip_scene()
	current_tooltip = scene.instantiate()
	tooltip_pivot.add_child(current_tooltip)
	current_tooltip.setup(node)

func _on_body_3d_display_interface(node: Node) -> void:
	if node == null:
		return

	if current_interface:
		_close_interface()
		return

	_close_interface()

	var scene = node.get_interface_scene()
	var interface = scene.instantiate()
	current_interface = interface
	self.add_child(interface)
	interface.setup(node)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _close_interface() -> void:
	if current_interface:
		current_interface.queue_free()
		current_interface = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
