extends Node2D

@onready var map_holder: Node2D = $MinimapHolder

const MINIMAP_TILE = preload("res://ui/minimap_tile.tscn")
const MAP_SPACING = 100

const OFFSETS: Array[Vector2i] = [Vector2i(0, 1), Vector2i(-1,0), Vector2i(1,0), Vector2i(0,-1)]

var map : Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("starting script")
	generate()


func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_SPACE):
		generate()


func generate():
	for c in map_holder.get_children():
		c.queue_free()
	map = await random_walk(10,10, 20)
	draw_map()

																	# skip chance with 2 adjacent, 3 adjacent
func random_walk(x:int, y:int, n_rooms:int = 10) -> Array:
	n_rooms = min(n_rooms, x*y)
	
	var visited : Array[Vector2i] = []
	
	var m = initialise_map(x,y)
	
	var start_pos = Vector2i(x/2, y/2)
	m[start_pos.y][start_pos.x] = 1
	visited.append(start_pos)
	
	print("starting at ", start_pos)
	
	var iterations = 1000
	
	while n_rooms > 0 and iterations > 0:
		iterations -= 1
		
		#select random cell
		var current_cell = visited.pick_random()
		
		#randomize adjacent cell
		var offsets = OFFSETS.duplicate()
		offsets.shuffle()
		#try all adjacent
		for i in range(4):
			var cell = current_cell + offsets[i]
			if is_valid_cell(cell, m):
				if m[cell.y][cell.x] != 1:
					var neighbours = get_adjacent_cells(cell, m)
					if !is_square(cell, m) and randf() > get_avoidance(neighbours):
						m[cell.y][cell.x] = 1
						visited.append(cell)
						n_rooms -= 1
						
						draw_map(m)
						await get_tree().create_timer(0.1/2).timeout
						break
	
	return m
	
	
func pure_random(x, y) -> Array:
	var m = initialise_map(x,y)
	# pure random
	for _y in y:
		for _x in x:
			m[_y][_x] = randi_range(0,1)
			print(m[_y][_x])
	return m


func draw_map(m = map):
	for y in m.size():
		for x in m[0].size():
			if m[y][x] == 1:
				var tile = MINIMAP_TILE.instantiate()
				tile.position.x = x * MAP_SPACING
				tile.position.y = y * MAP_SPACING
				map_holder.add_child(tile)
				
				var n = get_adjacent_cells(Vector2i(x,y), m)
				tile.get_node("Label").text = str(n) + "\n" + str(get_avoidance(n))


func initialise_map(x, y) -> Array:
	var m = []
	for _y in y:
		m.append([])
		for _x in x:
			m[_y].append(0)
	return m


func get_adjacent_cells(pos: Vector2i, m) -> int:
	var n = 0
	for i in OFFSETS:
		var cell = pos + i
		if is_valid_cell(cell, m):
			if m[cell.y][cell.x] == 1:
				n += 1
	return n


func is_valid_cell(pos, m) -> bool:
	return pos.x > 0 and pos.x < m[0].size() and pos.y > 0 and pos.y < m.size()


func is_square(cell, m) -> bool:
	var sets = [[Vector2i(0,1),Vector2i(1,1),Vector2i(1,0)],
				[Vector2i(1,0),Vector2i(1,-1),Vector2i(0,-1)],
				[Vector2i(0,-1),Vector2i(-1,-1),Vector2i(-1,0)],
				[Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,1)]]
	
	for offsets in sets:
		var n = 0
		for offset in offsets:
			if is_valid_cell(cell + offset, m) and m[(cell + offset).y][(cell + offset).x] == 1:
				n += 1
			else:
				n = 0
		if n == 3:
			return true
		
	return false

func get_avoidance(neighbours: int) -> float:	
	match neighbours:
		1:
			return 0
		2:
			return 0
		3:
			return 100
		4:
			return 10
		_:
			return 0
