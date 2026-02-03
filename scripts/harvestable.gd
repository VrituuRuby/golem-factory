extends StaticBody3D
class_name Harvestable

@export var available_amount: int = 5
@export var init_required_clicks = 3

var required_clicks: int = 3

func _ready() -> void:
    required_clicks = init_required_clicks
    pass

func click(collision_position: Vector3, click_force: int = 1) -> void:
    print("Clicked")
    required_clicks -= click_force
    if required_clicks == 0:
        print("Harvested")
        _on_harvested(collision_position)
        available_amount -= 1
        if available_amount == 0:
            _on_depleted()
            return
        required_clicks = init_required_clicks

func _on_depleted() -> void:
    print("Depleted")
    queue_free()
    pass;

func _on_harvested(collision_position: Vector3) -> void:
    pass;