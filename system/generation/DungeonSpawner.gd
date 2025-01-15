extends Node

class_name DungeonSpawner

signal generation_completed

@onready var generation: DungeonGeneration = $".."
@onready var player: Player = $"../Player"

@export var room_prefabs : Array[PackedScene]

@export var size_x : int = 10
@export var size_y : int = 10
@export var n_rooms : int = 20

@export var tile_size = 24

var spawned_rooms : Array[DungeonRoom]
var starting_room : DungeonRoom

var generated_map

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate()

func _input(event: InputEvent):
	if Input.is_key_pressed(KEY_R):
		generate()

func generate():
	generated_map = await generation.generate(size_x,size_y,n_rooms)
	spawn_dungeon()
	
	player.position = starting_room.position
	player.position.y += 0.5
	
	generation_completed.emit()

func spawn_dungeon():
	for y in range(size_y):
		for x in range(size_x):
			if generated_map[y][x] > 0:
				var room : DungeonRoom = room_prefabs.pick_random().instantiate() as DungeonRoom
				room.grid_position = Vector2i(x,y)
				room.position = Vector3(x * tile_size, 0, y * tile_size)
				spawned_rooms.append(room)
				add_child(room)
				
				if generated_map[y][x] == 2:
					starting_room = room
					print("set start room to ", starting_room.grid_position)
