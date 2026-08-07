class_name GolemTask
extends RefCounted

var name: String = "TaskName"

func can_start(golem: GolemClass) -> bool:
	return false

func update(delta: float, golem: GolemClass) -> void:
	pass