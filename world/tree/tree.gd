extends WorkableSource
class_name TreeClass

var CHOP_TREE_TASK = preload("res://golemns/tasks/chop_tree_task.gd")
@export var output_amount: int = 5;

signal work_finished()

var assigned_golems: Array[GolemClass] = []

func _do_work(actor: Actor, work_force: int = 1) -> void:
	var selected_item =  actor.inventory.slots[actor.inventory.selected_slot]

	if selected_item.itemData is not ToolItemData: 
		print("No tool selected")
		return
	if selected_item.itemData.tool_type != ToolItemData.ToolType.AXE: 
		print("Wrong tool selected")
		return

	super._do_work(actor, work_force)


func _on_work_finished(actor: Actor = null) -> void:
	for i in output_amount:
		var spawnPos = _spawn_item_height(global_position, i)
		ItemSpawner.spawn_item(output, spawnPos, Vector3.ZERO, 0.3)

	work_finished.emit()
	queue_free()

func _spawn_item_height(pos: Vector3, index: int):
	var step_height = 1;
	return Vector3(pos.x, pos.y + step_height * index, pos.z)

func on_secondary_action(actor: Actor) -> void:
	print("Tree on secondary action")
	if actor is not PlayerClass: return
	if not actor.selected_golem: return
	assign_golem(actor.selected_golem)

func assign_golem(golem: GolemClass) -> void:
	assigned_golems.append(golem)

func _process(delta: float) -> void:
	for golem in assigned_golems:
		if golem.assigned_task == null:
			print(CHOP_TREE_TASK.new())
			golem.assigned_task = CHOP_TREE_TASK.new()
			golem.assigned_task.target = self
			print("Assigned task to golem")

func on_action(actor: Actor) -> void:
	_do_work(actor)


		
