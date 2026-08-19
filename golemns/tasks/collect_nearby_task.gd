extends GolemTask
class_name CollectNearbyTask

enum COLLECT_STATE {
	IDLE,
	MOVING_TO_ITEM,
	MOVING_TO_STOCKPILE,
}

var target_stockpile: Stockpile
var valid_task: bool = false
var target_item: ItemPickup

var _state: int = COLLECT_STATE.IDLE
var state: 
	get: return _state
	set(value):
		print("current state: ", _state, ", new state: ", value)
		_state = value

func _init(stockpile: Stockpile, golem: GolemClass):
	target_stockpile = stockpile
	target_stockpile.available_pickups_update.connect(func (available_pickups):
		if state != COLLECT_STATE.IDLE: return
		if golem.inventory.slots[golem.inventory.selected_slot].itemData: return

		try_reserve_pickup(golem)
	)
	valid_task = true

func try_reserve_pickup(golem: GolemClass):
	var available_pickup = get_available_pickup(golem)
	if available_pickup:
		target_item = available_pickup
		state = COLLECT_STATE.MOVING_TO_ITEM
		available_pickup.reserved_pickup = true

func get_available_pickup(golem: GolemClass) -> ItemPickup:
	var closest_pickup: ItemPickup = null
	var closest_distance = INF

	for pickup in target_stockpile.available_pickups:
		if not pickup: return
		if pickup.reserved_pickup:
			continue
		
		var distance = golem.global_position.distance_to(pickup.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_pickup = pickup

	return closest_pickup

func update(delta: float, golem: GolemClass) -> void:
	match(state):
		COLLECT_STATE.IDLE:
			golem.info_label.text = "Idle"
			try_reserve_pickup(golem)
			return
		COLLECT_STATE.MOVING_TO_ITEM:
			golem.info_label.text = "Moving to Item"
			if !target_item or !is_instance_valid(target_item): 
				state = COLLECT_STATE.IDLE
				return
			
			if golem.global_position.distance_to(target_item.global_position) > 1:
				golem.state = GolemClass.STATES.MOVING
				golem.move_to(target_item.global_position)
				return
			else:
				if golem.inventory.add_item(target_item.item_data):
					golem.state = GolemClass.STATES.WORKING
					state = COLLECT_STATE.MOVING_TO_STOCKPILE
					target_item.queue_free()
			return
		COLLECT_STATE.MOVING_TO_STOCKPILE:
			golem.info_label.text = "Moving to Stockpile"
			if golem.global_position.distance_to(target_stockpile.global_position) > 1.5:
				golem.state = GolemClass.STATES.MOVING
				golem.move_to(target_stockpile.global_position)
				return
			else:
				golem.velocity = Vector3.ZERO
				golem.inventory.remove_selected()
				target_stockpile.increase_quantity()
				state = COLLECT_STATE.IDLE
			return
