extends Node

class_name PlayerHUD

@onready var pause_menu: Control = $PauseMenu
@onready var health_bar: TextureProgressBar = $HealthBar

var player: Node3D

var paused : bool = false

var health : Health


func _ready():
	player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		push_error("UI can't find player")
	else:
		health = player.get_node("Health") as Health
		if health == null:
			push_error("Can't find health")
		else:
			health.took_damage.connect(update_health_bar)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		toggle_pause()


func update_health_bar(_amount, _source):
	var fill : float = health.cur_health as float/health.max_health as float
	health_bar.set_value_no_signal(fill)
	print("bar val: ", fill)


func toggle_pause():
	if paused:
		paused = false
		pause_menu.hide()
		Engine.time_scale = 1
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		paused = true
		pause_menu.show()
		Engine.time_scale = 0
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
