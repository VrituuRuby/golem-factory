@tool
extends RigidBody3D
class_name ItemPickup

var velocity := Vector3.ZERO
var spawn_force = 5
var time = 0
var is_golem_holding := false

@export var mesh: MeshInstance3D
@export var collectableTimer: Timer

@export var item_data: ItemData:
	set(value):
		item_data = value
		_update_visual()

var isCollectable := false
var inCollectableArea := false

func _update_visual():
	if not is_inside_tree():
		return
		
	if item_data and mesh:
		mesh.mesh = item_data.mesh


func _ready() -> void:
	collectableTimer.start()
	var randomDir := Vector3(randf_range(-1, 1), 1, randf_range(-1, 1))
	axis_lock_angular_y = true
	axis_lock_angular_x = true
	axis_lock_angular_z = true

	_update_visual()

	apply_central_impulse(randomDir.normalized() * spawn_force)

func _process(delta: float) -> void:
	time += delta
	mesh.rotation_degrees.y = time * 90
	mesh.position.y = sin(time * 2) * 0.1 

	if(inCollectableArea and isCollectable):
		_pickup()

func _on_area_3d_body_entered(body: Node3D) -> void:
	inCollectableArea = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	inCollectableArea = false

func _pickup() -> void:
	if Inventory.add_item(item_data):
		queue_free()

func _on_collectable_timer_timeout() -> void:
	isCollectable = true
