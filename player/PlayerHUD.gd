extends Node

class_name PlayerHUD

@onready var pause_menu: Control = $PauseMenu
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var stamina_bar: TextureProgressBar = $StaminaBar
@onready var stamina_anim: AnimationPlayer = $AnimationPlayer

@onready var dungeon_generator: DungeonGeneration = $"../ViewBox/SubViewport/DungeonGenerationTest" as DungeonGeneration
@onready var dungeon_spawner: DungeonSpawner = $"../ViewBox/SubViewport/DungeonGenerationTest/DungeonSpawner" as DungeonSpawner
@onready var minimap_tile_holder: Node2D = $Minimap/MinimapTileHolder
@onready var player_icon: TextureRect = $Minimap/PlayerIcon

var player: Node3D

var paused : bool = false

var health : Health
var stamina : Stamina

var dead = false


func _ready():
	player = get_tree().get_first_node_in_group("player")
	
	dungeon_spawner.generation_completed.connect(on_world_generated)
	
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
		toggle_pause()


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


func on_world_generated():
	dungeon_generator.draw_map(dungeon_generator.map, minimap_tile_holder)

func _process(delta: float) -> void:
	var map_dimension = max(dungeon_spawner.size_x, dungeon_spawner.size_y)
	var player_01 = Vector2(player.global_position.x, player.global_position.z) / (dungeon_spawner.tile_size * map_dimension)
	minimap_tile_holder.position = -player_01 * dungeon_generator.MAP_SPACING * map_dimension * minimap_tile_holder.scale
	minimap_tile_holder.position += $Minimap.size/2
	player_icon.rotation = -player.rotation.y
