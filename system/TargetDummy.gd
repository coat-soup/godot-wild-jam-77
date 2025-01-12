extends Node3D

@onready var rb: RigidBody3D = $ConeTwistJoint3D/RigidBody3D


func _on_health_took_damage(amount, source) -> void:
	print("taking ", amount, " damage from ", source.name)
	rb.apply_force((rb.global_position - source.global_position).normalized()  * 10000)
