extends GolemTask
class_name ChopTreeTask

var target: TreeClass
var work_timer: float = 0.0
var valid_task: bool = false
var display_required_tool: bool = false

func _init():
	name = "Chop Tree"

func update(delta: float, golem: GolemClass) -> void:	
	if !target:
		valid_task = false
		return
	valid_task = true
	var selected_item =  golem.inventory.slots[golem.inventory.selected_slot]
	if selected_item.itemData is not ToolItemData: 
		if not display_required_tool:
			golem.extra_tooltip_labels.append("Chopping trees requires an axe")
			display_required_tool = true
		return
	display_required_tool = false

	if golem.global_position.distance_to(target.global_position) > 1:
		golem.state = GolemClass.STATES.MOVING
		golem.move_to(target.global_position)
		return
	
	golem.state = GolemClass.STATES.WORKING
	work_timer += delta
	if work_timer > golem.working_speed:
		work_timer = 0.0
		target._do_work(golem)
	pass