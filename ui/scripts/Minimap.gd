extends Control

@onready var dungeon_generator: DungeonGeneration = $"../../ViewBox/SubViewport/DungeonGenerationTest" as DungeonGeneration
@onready var dungeon_spawner: DungeonSpawner = $"../../ViewBox/SubViewport/DungeonGenerationTest/NavigationRegion3D/DungeonSpawner" as DungeonSpawner
@onready var tile_holder: Node2D = $MinimapTileHolder
@onready var player_icon: TextureRect = $PlayerIcon
@onready var map_tile_holder: Node2D = $"../Menu/MenuBackground/MapBackground/MapTileHolder"

const MINIMAP_TILE = preload("res://ui/scenes/minimap_tile.tscn")
const MAP_SPACING = 100

var player

var tile_dict = {}

func _ready():
	dungeon_spawner.generation_completed.connect(on_world_generated)
	
	player = get_tree().get_first_node_in_group("player")


func on_world_generated():
	for tile in tile_holder.get_children():
		tile_holder.remove_child(tile)
		tile.queue_free()
	for tile in map_tile_holder.get_children():
		map_tile_holder.remove_child(tile)
		tile.queue_free()
	tile_dict = {}
	
	draw_map(dungeon_generator.map, tile_holder)
	draw_map(dungeon_generator.map, map_tile_holder)
	for room in dungeon_spawner.spawned_rooms:
		room.room_entered.connect(on_room_entered)

	map_tile_holder.scale.x = (map_tile_holder.get_parent() as Control).size.x / (MAP_SPACING * max(dungeon_spawner.size_x, dungeon_spawner.size_y))
	map_tile_holder.scale.y = map_tile_holder.scale.x


func _process(delta: float) -> void:
	var map_dimension = max(dungeon_spawner.size_x, dungeon_spawner.size_y)
	var player_01 = Vector2(player.global_position.x, player.global_position.z) / (dungeon_spawner.tile_size * map_dimension)
	tile_holder.position = -player_01 * MAP_SPACING * map_dimension * tile_holder.scale
	tile_holder.position += size/2
	player_icon.rotation = -player.rotation.y

func draw_map(m, holder):
	tile_dict.get_or_add(holder, {})
	for c in holder.get_children():
			c.queue_free()
	for y in m.size():
		for x in m[0].size():
			if m[y][x] != 0:
				var tile = MINIMAP_TILE.instantiate()
				tile.position.x = x * MAP_SPACING
				tile.position.y = y * MAP_SPACING
				holder.add_child(tile)
				
				tile.get_node("Label").hide()
				tile.hide()
				
				(tile.get_node("ColorRect") as ColorRect).color = Color.DARK_GRAY
				tile_dict[holder].get_or_add(Vector2i(x,y), tile)


func on_room_entered(position):
	reveal_tile(position, tile_holder)
	reveal_tile(position, map_tile_holder)

func reveal_tile(position, holder):			
	var tile = tile_dict[holder].get(position)
	if !tile:
		return
	
	tile.show()
	
	var color = Color.WHITE
	print("entered room ", position, " of type ", dungeon_generator.map[position.y][position.x])
	match dungeon_generator.map[position.y][position.x]:
		2, 5:
			color = Color.BURLYWOOD
		3:
			color = Color.AQUAMARINE
		4:
			color = Color.ORCHID
	(tile.get_node("ColorRect") as ColorRect).color = color
	
	# show corridors
	var up = tile_dict[holder].get(position + Vector2i(0, -1))
	if up:
		up.show()
		up.get_node("CorridorDown").show()
		
	var down = tile_dict[holder].get(position + Vector2i(0, 1))
	if down:
		down.show()
		tile.get_node("CorridorDown").show()
		
	var left = tile_dict[holder].get(position + Vector2i(-1, 0))
	if left:
		left.show()
		left.get_node("CorridorRight").show()
		
	var right = tile_dict[holder].get(position + Vector2i(1, 0))
	if right:
		right.show()
		tile.get_node("CorridorRight").show()
