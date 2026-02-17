extends CharacterBody3D
class_name GolemClass

enum STATES {
	IDLE,
	MOVING,
	WORKING,
}

@export var assigned_workable: Workable
var state: int = STATES.IDLE

@onready var state_label : Label3D = $StateLabel
@onready var work_timer: Timer = $Timer
@onready var ray_cast: RayCast3D = $RayCast3D

const SPEED = 5.0
const REACH = 1

func _ready() -> void:
	work_timer.connect("timeout",func (): _on_work_timer_timeout())
	ray_cast.target_position =  Vector3(0, 0, -REACH)

func assign_workable(workable: Workable) -> void:
	assigned_workable = workable
	state = STATES.MOVING

func _physics_process(delta: float) -> void:
	if not assigned_workable:
		work_timer.stop()
		state = STATES.IDLE

	match state:
		STATES.IDLE:
			state_label.text = "Idle"
			if assigned_workable:
				state = STATES.MOVING
		STATES.MOVING:
			state_label.text = "Moving"
			var desired_direction := assigned_workable.global_position - global_position
			desired_direction.y = 0;

			var collider := ray_cast.get_collider() as Node
			if collider != assigned_workable:
				velocity = desired_direction.normalized() * SPEED
				look_at(global_position + desired_direction.normalized(), Vector3.UP)
			else: 
				state = STATES.WORKING
				work_timer.start()
		
		STATES.WORKING:
			var collider = ray_cast.get_collider() as Node
			if not ray_cast.is_colliding() || collider != assigned_workable:
				state = STATES.MOVING
				return
			state_label.text = "%.2f" % work_timer.time_left
			velocity = Vector3.ZERO	
		
	for body in get_slide_collision_count():
			var collision = get_slide_collision(body)
			if collision.get_collider() is GolemClass:
				velocity += collision.get_normal() * 2.0

	move_and_slide()

func _on_work_timer_timeout() -> void:
	work_timer.start()
	print("timeout")
	assigned_workable._do_work(1, ray_cast.get_collision_point())
