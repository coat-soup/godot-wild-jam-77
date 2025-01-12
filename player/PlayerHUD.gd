extends Node

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var health: Health = $"../Health"


func _on_health_took_damage() -> void:
	update_health_bar()
	
func update_health_bar():
	var fill : float = health.cur_health as float/health.max_health as float
	health_bar.set_value_no_signal(fill)
	print("bar val: ", fill)
