extends WorkableSource
class_name TreeFarm

enum STATE {EMPTY, GROWING, READY}
var WOOD = preload("res://items/resources/wood.tres")
var TREE_SCENE = preload("res://world/tree/tree.tscn")

@onready var treeMesh = $MultiMeshInstance3D
var tree: WorkableSource;

var timePassed = 0.0
var state: STATE = STATE.EMPTY

const GROW_TIME = 5.0

func _ready():
	super()
	can_work = false
	treeMesh.visible = false
	pass

func _process(delta):
	if state == STATE.GROWING:
		timePassed += delta
		var t = timePassed / GROW_TIME
		var s = lerp(0.1, 1.0, t)
		treeMesh.scale = Vector3.ONE * s

		if timePassed > GROW_TIME:
			on_growth_finished()

func set_is_planted(value: bool):
	if value:
		treeMesh.scale = Vector3(0.1, 0.1, 0.1)
		treeMesh.visible = true
		state = STATE.GROWING
		timePassed = 0.0
	else:
		treeMesh.visible = false

func on_secondary_action(actor:Actor):
	if state != STATE.EMPTY: return
	var selected_item := actor.inventory.slots[actor.inventory.selected_slot]
	if selected_item.itemData == WOOD:
		set_is_planted(true)
		actor.inventory.remove_selected()

func on_tree_harvested():
	state = STATE.EMPTY

func on_growth_finished():
	set_is_planted(false)
	state = STATE.READY
	tree = TREE_SCENE.instantiate()
	tree.global_position = global_position
	tree.work_finished.connect(func(): on_tree_harvested())
	get_tree().get_root().add_child(tree)
