extends WorkableSource

@onready var label_3d := $Label3D as Label3D

func _ready() -> void:
	super._ready()
	label_3d.text = "%d/%d" % [current_amount, available_amount]

func _on_work_finished(pos: Vector3, entityPos: Vector3 = Vector3.ZERO) -> void:
	super._on_work_finished(pos, entityPos)
	label_3d.text = "%d/%d" % [current_amount, available_amount]
