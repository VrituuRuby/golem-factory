extends WorkableSource

@onready var label_3d := $Label3D as Label3D

func _ready() -> void:
	super._ready()
	label_3d.text = "%d/%d" % [current_amount, available_amount]

func _on_work_finished(pos: Vector3) -> void:
	super._on_work_finished(pos)
	label_3d.text = "%d/%d" % [current_amount, available_amount]
