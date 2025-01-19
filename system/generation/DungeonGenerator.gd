extends Node3D

class_name DungeonGeneration

@onready var map_holder: Node2D = $MinimapHolder

const OFFSETS: Array[Vector2i] = [Vector2i(0, 1), Vector2i(-1,0), Vector2i(1,0), Vector2i(0,-1)]

var map : Array

  # [minFountain, maxFountain, minBody, maxBody]
var special_distribution: Array[int] = [2,3,3,5]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return
	await generate()
	#draw_map(map, map_holder)


func generate(size_x = 10, size_y = 10, n_rooms = 20) -> Array:
	map = await random_walk(size_x,size_y, n_rooms)
	map = assign_special_rooms(map, special_distribution)
	return map


func random_walk(x:int, y:int, n_rooms:int = 10, display_delay:float=0) -> Array:
	n_rooms = min(n_rooms, x*y)
	
	var visited : Array[Vector2i] = []
	
	var m = initialise_map(x,y)
	
	var start_pos = Vector2i(x/2, y/2)
	m[start_pos.y][start_pos.x] = 1
	visited.append(start_pos)
	
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
						
						#draw_map(m, map_holder)
						await get_tree().create_timer(display_delay).timeout
						break
	
	return m
	
	
static func pure_random(x, y) -> Array:
	var m = initialise_map(x,y)
	# pure random
	for _y in y:
		for _x in x:
			m[_y][_x] = randi_range(0,1)
	return m


static func initialise_map(x, y) -> Array:
	var m = []
	for _y in y:
		m.append([])
		for _x in x:
			m[_y].append(0)
	return m


static func get_adjacent_cells(pos: Vector2i, m) -> int:
	var n = 0
	for i in OFFSETS:
		var cell = pos + i
		if is_valid_cell(cell, m):
			if m[cell.y][cell.x] == 1:
				n += 1
	return n


static func is_valid_cell(pos, m) -> bool:
	return pos.x > 0 and pos.x < m[0].size() and pos.y > 0 and pos.y < m.size()


static func is_square(cell, m) -> bool:
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


static func get_avoidance(neighbours: int) -> float:	
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


static func assign_special_rooms(m, distribution) -> Array:
	# 0 = empty, 1 = standard room, 2 = start room, 3 = fountain room, 4 = body part room, 5 = end room
	
	var special_room = get_random_room_of_value(m, 1)
	if is_valid_cell(special_room, m):
		m[special_room.y][special_room.x] = 2
	special_room = get_random_room_of_value(m, 1)
	if is_valid_cell(special_room, m):
		m[special_room.y][special_room.x] = 5
		
	#fountains
	for x in range(randi_range(distribution[0], distribution[1])):
		special_room = get_random_room_of_value(m, 1)
		if is_valid_cell(special_room, m):
			m[special_room.y][special_room.x] = 3
	#bodyparts
	for x in range(randi_range(distribution[2], distribution[3])):
		special_room = get_random_room_of_value(m, 1)
		if is_valid_cell(special_room, m):
			m[special_room.y][special_room.x] = 4
	
	return m


static func get_random_room_of_value(m, value: int) -> Vector2i:
	var iter = 1000
	while iter > 0:
		iter -= 1
		var rand_room = Vector2i(randi() % m[0].size(), randi() % m.size())
		if m[rand_room.y][rand_room.x] == value:
			return rand_room
			
	return Vector2i(-1,-1)
