extends CharacterBody3D
class_name GolemClass

enum STATES {
	IDLE,
	MOVING,
	WORKING,
	PICKING_ITEM,
	MOVING_TO_STOCKPILE,
	DROPPING_ITEM
}

var state: int = STATES.IDLE

var holding_item: ItemData = null;
var target_item: ItemPickup = null;
var assigned_interactable: Interactable = null;

@onready var state_label : Label3D = $StateLabel
@onready var info_label : Label3D = $InfoLabel
@onready var work_timer: Timer = $Timer
@onready var ray_cast: RayCast3D = $RayCast3D
@onready var holding_item_position: Marker3D = $HoldingItemPosition

const SPEED = 2.5
const REACH = 1

func _ready() -> void:
	work_timer.connect("timeout",func (): _on_work_timer_timeout())
	ray_cast.target_position =  Vector3(0, 0, -REACH)

func assign_workable(workable: Workable) -> void:
	assigned_interactable = workable

func assign_stockpile(stockpile: Stockpile) -> void:
	assigned_interactable = stockpile

func _process(delta: float) -> void:
	match state:
		STATES.IDLE:
			state_label.text = "Idle"

			velocity = Vector3.ZERO
			if not assigned_interactable: return
			if assigned_interactable is Workable:
				state = STATES.MOVING
			if assigned_interactable is	Stockpile:
				if not assigned_interactable.stock_item:
					info_label.visible = true;
					info_label.text = "Stockpile has no selected item"
					return
				else:
					info_label.visible = false;
				
				var all_items = get_tree().get_nodes_in_group("item_pickup")
				var closest_item = null
				var closest_distance = INF
				for item in all_items:
					if item.item_data != assigned_interactable.stock_item: continue
					var distance = global_position.distance_to(item.global_position)

					if distance < closest_distance:
						closest_distance = distance
						closest_item = item

				target_item = closest_item
				if target_item:
					state = STATES.PICKING_ITEM

		STATES.MOVING:
			state_label.text = "Moving"
			var desired_direction := assigned_interactable.global_position - global_position
			desired_direction.y = 0;

			var collider := ray_cast.get_collider() as Node
			if collider != assigned_interactable:
				move_to(assigned_interactable.global_position)
			else: 
				state = STATES.WORKING
				work_timer.start()
		
		STATES.WORKING:
			if not assigned_interactable:
				work_timer.stop()
				state = STATES.IDLE
				return

			var collider = ray_cast.get_collider() as Node
			if not ray_cast.is_colliding() || collider != assigned_interactable:
				state = STATES.MOVING
				return
			state_label.text = "%.2f" % work_timer.time_left
			velocity = Vector3.ZERO	
		
		STATES.PICKING_ITEM:
			state_label.text = "Picking Item"
			if not target_item:
				state = STATES.IDLE
				info_label.visible = true
				info_label.text = "No item to pick"
				return
			
			move_to(target_item.global_position)

			var distance_to_item := global_position.distance_to(target_item.global_position)
			if distance_to_item <= REACH:
				var item_mesh = MeshInstance3D.new()
				item_mesh.mesh = target_item.item_data.mesh.duplicate()
				holding_item_position.add_child(item_mesh)
			
				target_item.queue_free()
				target_item = null
				state = STATES.MOVING_TO_STOCKPILE	
				return


		STATES.MOVING_TO_STOCKPILE:
			state_label.text = "Moving to Stockpile"
			if not assigned_interactable or not assigned_interactable is Stockpile:
				state = STATES.IDLE
				return
			
			move_to(assigned_interactable.global_position)
			if global_position.distance_to(assigned_interactable.global_position) <= 2.5:
				state = STATES.DROPPING_ITEM

		STATES.DROPPING_ITEM:
			if not assigned_interactable or  not assigned_interactable is Stockpile:
				state = STATES.IDLE
				return

			holding_item_position.get_child(0).queue_free()

			assigned_interactable.increase_quantity()

			state = STATES.IDLE

			return
		
	move_and_slide()

func move_to(target: Vector3) -> void:
	var desired_direction := target - global_position
	desired_direction.y = 0;

	velocity = desired_direction.normalized() * SPEED
	if desired_direction.length() > 0.1:
		look_at(global_position + desired_direction.normalized(), Vector3.UP)

func _on_work_timer_timeout() -> void:
	work_timer.start()
	assigned_interactable._do_work(1, ray_cast.get_collision_point(), global_position)
