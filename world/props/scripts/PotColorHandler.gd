extends Node3D

@export var color : Color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pot = get_child(0) as MeshInstance3D
	pot.mesh.surface_get_material(0).albedo_color = color
