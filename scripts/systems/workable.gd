extends StaticBody3D
class_name Workable

@export var required_work: int = 10
@export var work_counter: int = 0

var can_work: bool = false

func _do_work(work_force: int = 1, pos: Vector3 = Vector3.ZERO):
	if not can_work: return

	work_counter += work_force
	if work_counter >= required_work:
		work_counter = 0
		_on_work_finished(pos)

func _on_work_finished(pos: Vector3):
	pass