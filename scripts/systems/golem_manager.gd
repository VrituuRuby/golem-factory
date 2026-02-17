extends Node
class_name GolemManager

var selected_golem: GolemClass = null

func set_golem(golem: GolemClass) -> void:
	selected_golem = golem

func assign_workable(workable: Workable) -> void:
	if not selected_golem: return

	selected_golem.assign_workable(workable)
	selected_golem = null