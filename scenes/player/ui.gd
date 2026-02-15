extends Control

const LABEL = preload("res://scenes/ui/resourse_label.tscn")

@onready var _list: VBoxContainer = $InventoryList
@onready var _build_panel: Panel = $Panel
@onready var _blueprints_list: VBoxContainer = $Panel/BlueprintsList
@onready var _blueprint_option_scene: PackedScene = preload("res://scenes/ui/blueprint_option.tscn")

@onready var _progress_bar: TextureProgressBar = $TextureProgressBar

@export var builds_data: Array[BuildData]  

signal select_blueprint(build_data: BuildData)

var is_build_panel_open := false

func _ready() -> void:
	Inventory.update.connect(_update_inventory)

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

func _update_inventory(items: Dictionary) -> void:
	for child in _list.get_children():
		child.queue_free()

	for item in items.keys():
		var amount = items[item]
		var label = LABEL.instantiate()
		label.text = "%s: %s" % [item.name, amount]
		label.modulate = item.material.albedo_color
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


func _on_character_body_3d_display_progress(workable: Workable) -> void:
	if workable == null:
		_progress_bar.visible = false
		_progress_bar.value = 0
	else: 
		_progress_bar.visible = true
		var progress = float(workable.work_counter) / float(workable.required_work) * 100.0
		_progress_bar.value = progress
