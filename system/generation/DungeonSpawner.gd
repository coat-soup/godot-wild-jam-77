extends Node

class_name DungeonSpawner

signal generation_completed

@onready var generator: DungeonGeneration = $"../.."
@onready var player: Player
@onready var navmesh: NavigationRegion3D = $".."

@export var room_prefabs : Array[PackedScene]

@export var size_x : int = 10
@export var size_y : int = 10
@export var n_rooms : int = 20

@export var tile_size = 33

var spawned_rooms : Array[DungeonRoom]
var starting_room : DungeonRoom

const FOUNTAIN_ROOM = preload("res://world/dungeonrooms/fountain_room.tscn")
const STARTING_ROOM = preload("res://world/dungeonrooms/starting_room.tscn")
const UPGRADE_ROOMS = [preload("res://world/dungeonrooms/upgrade_room_01.tscn"), preload("res://world/dungeonrooms/upgrade_room_02.tscn")]
const ENDING_ROOM = preload("res://world/dungeonrooms/ending_room.tscn")

var generated_map

var level_iteration = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	generate()

func _input(_event: InputEvent):
	if Input.is_key_pressed(KEY_R) and false:
		generate()

func generate():
	level_iteration += 1
	print("LEVEL ", level_iteration)
	for room in spawned_rooms:
		remove_child(room)
		room.queue_free()
	spawned_rooms = []
	
	generated_map = await generator.generate(size_x,size_y,n_rooms)
	spawn_dungeon()
	set_hallways()
	
	player.position = starting_room.position
	player.position.y += 2.5
	
	navmesh.bake_navigation_mesh()
	generation_completed.emit()

func spawn_dungeon():
	for y in range(size_y):
		for x in range(size_x):
			if generated_map[y][x] > 0:
				var pref
				match generated_map[y][x]:
					2: pref = STARTING_ROOM
					3: pref = FOUNTAIN_ROOM
					4: pref = UPGRADE_ROOMS.pick_random()
					5: pref = ENDING_ROOM
					_: pref = room_prefabs.pick_random()
					
				var room : DungeonRoom = pref.instantiate() as DungeonRoom
				room.grid_position = Vector2i(x,y)
				room.position = Vector3(x * tile_size, 0, y * tile_size)
				spawned_rooms.append(room)
				add_child(room)
				
				if generated_map[y][x] == 2:
					starting_room = room
					print("set start room to ", starting_room.grid_position)

func set_hallways():
	for room in spawned_rooms:
		var up = room.grid_position + Vector2i(0,-1)
		room.set_sided_connector("Up", DungeonGeneration.is_valid_cell(up, generator.map) and generator.map[up.y][up.x] > 0)
		
		var down = room.grid_position + Vector2i(0,1)
		room.set_sided_connector("Down", DungeonGeneration.is_valid_cell(down, generator.map) and generator.map[down.y][down.x] > 0)
		
		var left = room.grid_position + Vector2i(-1,0)
		room.set_sided_connector("Left", DungeonGeneration.is_valid_cell(left, generator.map) and generator.map[left.y][left.x] > 0)
		
		var right = room.grid_position + Vector2i(1,0)
		room.set_sided_connector("Right", DungeonGeneration.is_valid_cell(right, generator.map) and generator.map[right.y][right.x] > 0)
