class_name ItemData
extends Resource

@export var name: String
@export var mesh: Mesh

@export var stackable := true
@export var max_stack := 10

## Scale of the mesh.
## In case meshes are too big or to little to fit inside collider.
@export_range(0.0, 1) var mesh_scale: float = 1.0

## Rotation in degrees.
## In case meshes are more interestingly rotated.
@export var mesh_rotation: Vector3 = Vector3.ZERO

## Mesh position translation.
## In case of weird origin points.
@export var mesh_offset: Vector3 = Vector3.ZERO
