extends Resource
class_name BuildData

@export var build: PackedScene;
@export var input: Dictionary[ItemData, int] = {};
@export var name: String;

@export var required_work = 50;
