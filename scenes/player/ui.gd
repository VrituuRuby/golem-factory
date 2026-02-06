extends Control

const LABEL = preload("res://scenes/ui/resourse_label.tscn")

@onready var _list: VBoxContainer = $VBoxContainer

func _ready() -> void:
	Inventory.update.connect(_update_ui)

func _update_ui(items: Dictionary) -> void:
	for child in _list.get_children():
		child.queue_free()

	for item in items.keys():
		var amount = items[item]
		var label = LABEL.instantiate()
		label.text = "%s: %s" % [item.name, amount]
		label.modulate = item.mesh_color
		_list.add_child(label)
