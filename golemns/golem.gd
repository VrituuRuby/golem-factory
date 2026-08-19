extends Actor
class_name GolemClass

@onready var info_label : Label3D = $InfoLabel
@onready var holding_item_position: Marker3D = $HoldingItemPosition

const TOOLTIP_SCENE = preload("res://golemns/ui/tooltip/golem_tooltip.tscn")

const SPEED = 2.5
const REACH = 1
@export var working_speed = 1.0

enum STATES {
	IDLE,
	MOVING,
	WORKING
}

var state: int = STATES.IDLE

var assigned_task: GolemTask
var extra_tooltip_labels: Array[String] = []


func _ready() -> void:
	ray_cast.target_position =  Vector3(0, 0, -REACH)
	inventory.update.connect(func ():
		var selected_slot := inventory.slots[inventory.selected_slot]
		if not selected_slot.is_empty():
			var item_mesh = selected_slot.itemData.mesh
			if item_mesh:
				var mesh = MeshInstance3D.new()
				mesh.mesh = item_mesh
				holding_item_position.add_child(mesh)
		else:
			for child in holding_item_position.get_children():
				child.queue_free()
	)

func _process(delta: float) -> void:
	# info_label.visible = false
	if not is_on_floor():
		velocity.y -= 12 * delta

	if assigned_task:
		assigned_task.update(delta, self)
		if not assigned_task.valid_task:
			assigned_task = null

	if extra_tooltip_labels.size() > 0:
		info_label.text = "!"
		# info_label.visible = true
	else:
		# info_label.visible = false
		pass
	
	move_and_slide()

func move_to(target: Vector3) -> void:
	var desired_direction := target - global_position
	desired_direction.y = 0;

	velocity = desired_direction.normalized() * SPEED
	if desired_direction.length() > 0.1:
		look_at(global_position + desired_direction.normalized(), Vector3.UP)

func on_secondary_action(actor: Actor) -> void:
	if actor is not PlayerClass:
		return

	var slot := actor.inventory.get_selected_slot()

	if slot.is_empty():
		return

	var tool := slot.itemData as ToolItemData
	if tool != null and tool.tool_type == ToolItemData.ToolType.STAFF:
		actor.selected_golem = self
		return

	if inventory.add_item(slot.itemData):
		actor.inventory.remove_selected()

func get_tooltip_scene() -> PackedScene:
	return TOOLTIP_SCENE
