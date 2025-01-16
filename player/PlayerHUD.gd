extends Node

class_name PlayerHUD

@onready var dungeon_spawner: DungeonSpawner = $"../ViewBox/SubViewport/DungeonGenerationTest/NavigationRegion3D/DungeonSpawner" as DungeonSpawner

@onready var menu: Control = $Menu
@onready var pause_menu: Control = $PauseMenu
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var stamina_bar: TextureProgressBar = $StaminaBar
@onready var stamina_anim: AnimationPlayer = $AnimationPlayer

@onready var loading_screen: ColorRect = $LoadingScreen

@onready var minimap_tile_holder: Node2D = $Minimap/MinimapTileHolder
@onready var player_icon: TextureRect = $Minimap/PlayerIcon

var player: Node3D

var paused : bool = false
var in_menu : bool = false

var health : Health
var stamina : Stamina

var dead = false


func _ready():
	loading_screen.show()
	dungeon_spawner.generation_completed.connect(on_generation_finished)
	
	player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		push_error("UI can't find player")
	else:		
		health = player.get_node("Health") as Health
		if health == null:
			push_error("UI can't find health")
		else:
			health.took_damage.connect(update_health_bar)
			health.healed.connect(update_health_bar)
			health.died.connect(on_die)
		stamina = player.get_node("Stamina")
		if stamina == null:
			push_error("UI can't find stamina")
		else:
			stamina.stamina_changed.connect(update_stamina_bar)
			stamina.alert_depleted.connect(alert_stamina_bar)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		if in_menu:
			toggle_menu()
		else:
			toggle_pause()
	if event.is_action_pressed("menu"):
		toggle_menu()


func update_health_bar(_amount = null, _source = null):
	var fill : float = health.cur_health as float/health.max_health as float
	health_bar.set_value_no_signal(fill)


func update_stamina_bar():
	var fill : float = stamina.cur_stamina/stamina.max_stamina
	stamina_bar.set_value_no_signal(fill)


func toggle_pause():
	if paused and !dead:
		paused = false
		pause_menu.hide()
		Engine.time_scale = 1
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		paused = true
		pause_menu.show()
		Engine.time_scale = 0
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED


func alert_stamina_bar():
	stamina_anim.play("stamina_alert_anim")


func on_die():
	dead = true
	pause_menu.get_node("MarginContainer/VBoxContainer/Resume").hide()
	$DeathText.show()
	toggle_pause()


func toggle_menu():
	in_menu = !in_menu
	
	if in_menu:
		menu.show()
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	else:
		menu.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func on_generation_finished():
	loading_screen.hide()
