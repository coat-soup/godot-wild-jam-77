extends Node

@onready var circle_001: MeshInstance3D = $"../Armature/Skeleton3D/Circle_001/Circle_001"
@onready var circle_006: MeshInstance3D = $"../Armature/Skeleton3D/Circle_006/Circle_006"

@export var spin_speed : float = 1000

func _physics_process(delta: float) -> void:
	if spin_speed != 0:
		circle_001.rotate_y(deg_to_rad(spin_speed * delta))
		circle_006.rotate_y(deg_to_rad(spin_speed * delta))
