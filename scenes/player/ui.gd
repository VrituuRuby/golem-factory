extends Control

const LABEL = preload("res://scenes/ui/resourse_label.tscn")

@onready var _list: VBoxContainer = $InventoryList
@onready var _build_panel: Panel = $Panel
@onready var _blueprints_list: VBoxContainer = $Panel/BlueprintsList
@onready var _blueprint_option_scene: PackedScene = preload("res://scenes/ui/blueprint_option.tscn")
@onready var _action_label: Label = $ActionTextLabel

@onready var _progress_bar: TextureProgressBar = $TextureProgressBar

@export var builds_data: Array[BuildData]  

signal select_blueprint(build_data: BuildData)

var is_build_panel_open := false

func _ready() -> void:
	Inventory.update.connect(_update_inventory)
	_update_inventory(Inventory.items, null)
	_update_build_panel()

func _update_build_panel() -> void:
	for child in _blueprints_list.get_children():
		child.queue_free()

	for build_data in builds_data:
		var blueprint_option = _blueprint_option_scene.instantiate()
		blueprint_option.setup(build_data)
		blueprint_option.select_build.connect(
		func (bd: BuildData):
			print("Selected blueprint")
			select_blueprint.emit(bd)
			is_build_panel_open = false
			_toggle_build_panel()
		)
		_blueprints_list.add_child(blueprint_option)

func _update_inventory(items: Dictionary, selected_item: ItemData) -> void:
	for child in _list.get_children():
		child.queue_free()

	for item in items.keys():
		var amount = items[item]
		var label: Label = LABEL.instantiate()
		label.text = "%s: %s" % [item.name, amount]
		label.label_settings = label.label_settings.duplicate()
		if item == selected_item:
			label.label_settings.font_color = Color.YELLOW
		_list.add_child(label)
	
	_update_build_panel()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_build_panel"):
		is_build_panel_open = not is_build_panel_open
		_toggle_build_panel()

func _toggle_build_panel() -> void:
	if is_build_panel_open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_build_panel.visible = true;
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_build_panel.visible = false;


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
		_progress_bar.visible = true
		var progress = float(interactable.work_counter) / float(interactable.required_work) * 100.0
		_progress_bar.value = progress
