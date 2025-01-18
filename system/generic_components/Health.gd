extends Node

class_name Health

signal took_damage
signal healed
signal died

@onready var parent : Node3D = get_parent()

@export var max_health : float = 100
var cur_health : float

func _ready() -> void:
	cur_health = max_health

func take_damage(amount : float, source : Node3D):
	#print(name, " taking ", amount, " damage")
	cur_health -= amount
	took_damage.emit(amount, source)
	
	
	if cur_health <= 0:
		die()
	
func heal(amount):
	cur_health = min(cur_health + amount, max_health)
	healed.emit()
	
func die():
	print(parent.name, " died")
	died.emit()
	parent.queue_free()
