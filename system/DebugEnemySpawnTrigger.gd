extends Node3D

const ENEMY_CLUSTER_SPAWN = preload("res://system/enemy_cluster_spawn.tscn")



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		var enemies = ENEMY_CLUSTER_SPAWN.instantiate()
		add_child(enemies)
