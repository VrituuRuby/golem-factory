extends StaticBody3D
class_name Harvestable

@export var available_amount: int = 10
@export var init_required_clicks = 3

var current_clicks: int = 0
var current_amount: int 

func _ready() -> void:
    print("Harvestable ready")
    current_amount = available_amount
    print(current_amount, available_amount)
    pass

func click(collision_position: Vector3, click_force: int = 1) -> void:
    print("Clicked")
    current_clicks += click_force
    if current_clicks >= init_required_clicks:
        current_amount -= 1
        current_clicks = 0
        if current_amount == 0:
            _on_depleted()
            return
        _on_harvested(collision_position)

func _on_depleted() -> void:
    print("Depleted")
    queue_free()
    pass;

func _on_harvested(collision_position: Vector3) -> void:
    pass;