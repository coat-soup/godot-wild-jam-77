extends Node

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var player: Node3D = $"../ViewBox/SubViewport/DungeonTest/Player"


var health : Health

func _ready():
	if player == null:
		push_error("UI can't find player")
	else:
		health = player.get_node("Health") as Health
		if health == null:
			push_error("Can't find health")
		else:
			health.took_damage.connect(update_health_bar)
	
func update_health_bar(_amount, _source):
	var fill : float = health.cur_health as float/health.max_health as float
	health_bar.set_value_no_signal(fill)
	print("bar val: ", fill)
