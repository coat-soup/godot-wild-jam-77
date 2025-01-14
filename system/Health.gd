extends Node

class_name Health

signal took_damage
signal died

@onready var parent : Node3D = get_parent()

@export var max_health : int = 100
var cur_health : int

func _ready() -> void:
	cur_health = max_health

func take_damage(amount : int, source : Node3D):
	print("taking damage")
	cur_health -= amount
	took_damage.emit(amount, source)
	
	
	if cur_health <= 0:
		die()
	
func die():
	print(parent.name, " died")
	died.emit()
	parent.queue_free()
