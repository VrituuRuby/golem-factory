extends Workable
class_name Blueprint

@export var build_data: BuildData

@onready var area_3d: Area3D = $Area3D

var build_node: Node3D
var build_mesh: MeshInstance3D

var build_collision: CollisionShape3D

var is_placed := false;

var can_place := false;

const RED_MATERIAL := preload("res://assets/materials/red.tres")
const BLUE_MATERIAL := preload("res://assets/materials/blue.tres")

func _ready() -> void:
	required_work = build_data.required_work
	build_node = build_data.build.instantiate() as Node3D

	build_mesh = build_node.get_node("MeshInstance3D").duplicate() as MeshInstance3D
	build_collision = build_node.get_node("CollisionShape3D").duplicate() as CollisionShape3D

	build_mesh.transparency = 0.6
	build_mesh.material_overlay = BLUE_MATERIAL

	var area_3d_collision_shape = build_collision.duplicate()
	area_3d.add_child(area_3d_collision_shape)

	add_child(build_mesh)

func _physics_process(delta: float) -> void:
	if is_placed: return

	_validate_place()

func _validate_place():
	var bodies: Array[Node3D] = area_3d.get_overlapping_bodies() as Array[Node3D]

	var touching_ground = false
	var touching_other = false

	for body in bodies:
		if body.is_in_group("ground"):
			touching_ground = true
		else:
			touching_other = true

	if touching_ground and not touching_other:
		can_place = true
	else:
		can_place = false

	if can_place:
		build_mesh.material_overlay = BLUE_MATERIAL
	else:
		build_mesh.material_overlay = RED_MATERIAL


func place() -> bool:
	if not can_place: return false
	is_placed = true
	can_work = true
	add_child(build_collision)
	return true

func _do_work(work_force: int = 1, pos: Vector3 = Vector3.ZERO):
	if not is_placed: return;
	super._do_work(work_force, pos)

func _on_work_finished(pos: Vector3):
	if not is_placed: return
	build_node.global_position = self.global_position
	build_node.rotation = self.rotation

	get_tree().get_root().add_child(build_node)
	queue_free()

	
