extends Node3D

const ENEMY_CLUSTER_SPAWN = preload("res://system/debug_testing/enemy_cluster_spawn.tscn")
const ENEMY = preload("res://enemies/enemy.tscn")


func _on_area_3d_multi_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		var enemies = ENEMY_CLUSTER_SPAWN.instantiate()
		add_child(enemies)


func _on_area_3d_single_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		var enemy = ENEMY.instantiate()
		add_child(enemy)


func _on_area_3d_heal_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		var health = body.get_node("Health") as Health
		if health:
			health.heal(100)
