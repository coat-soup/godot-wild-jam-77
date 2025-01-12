extends Node3D

var bloody_mat = preload("res://world/props/materials/ritualtable_bloody_mat.tres")


func _on_trigger_area_body_entered(body: Node3D) -> void:
	if is_instance_of(body, CharacterBody3D):
		for mesh in $TableCut.get_children():
			mesh = mesh as MeshInstance3D
			mesh.set_surface_override_material(0, bloody_mat)
