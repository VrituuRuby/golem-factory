extends WorkableSource

@onready var label_3d := $Label3D as Label3D

func _ready() -> void:
	super._ready()
	print(output)
	label_3d.text = "%d/%d" % [current_amount, available_amount]

func _on_work_finished(actor: Actor = null) -> void:
	super._on_work_finished(actor)
	label_3d.text = "%d/%d" % [current_amount, available_amount]
