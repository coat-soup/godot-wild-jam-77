extends Node3D

class_name DungeonRoom

signal room_entered

var grid_position : Vector2i

func _on_enter_room_trigger_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		room_entered.emit(grid_position)
