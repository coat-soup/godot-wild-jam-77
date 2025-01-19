extends Node3D

class_name DungeonRoom

signal room_entered
signal room_completed

@export var enemies : Array[EnemySpawns]
var total_enemies_to_spawn: Array[PackedScene]
@export var spawn_interval = 2
var enemies_to_kill : int

var completed : bool = false
var triggered : bool = false

var grid_position : Vector2i

var gate_triggers: Array[Area3D]

var gate_position := Vector2(1.994, -0.1)
var gate_pos : float


func _ready():
	gate_triggers = [get_node("CorridorUp/GateTriggerArea"),
					 get_node("CorridorDown/GateTriggerArea"),
					 get_node("CorridorLeft/GateTriggerArea"),
					 get_node("CorridorRight/GateTriggerArea")]
	for gate in gate_triggers:
		if gate:
			gate.body_entered.connect(trigger_gates)
			
	for enemy in enemies:
		for i in enemy.num_spawns:
			total_enemies_to_spawn.append(enemy.enemy)
			enemies_to_kill += 1
	total_enemies_to_spawn.shuffle()
	# level 1 = 100% spawn interval, level 7 = 0%
	spawn_interval = spawn_interval * (1.0 - (((get_parent() as DungeonSpawner).level_iteration-1)/7.0))
	print("spawn intervarl for ", name, " is ", spawn_interval)


func _on_enter_room_trigger_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		room_entered.emit(grid_position)


func set_sided_connector(side: String, is_connected: bool):
	var sealed = get_node("Sealed" + side) as GridMap
	var connected = get_node("Corridor" + side) as GridMap
	if is_connected:
		connected.show()
		remove_child(sealed)
	else:
		sealed.show()
		remove_child(connected)


func trigger_gates(body: Node3D):
	if triggered or enemies.size() == 0:
		return
		
	if body.name == "Player":
		triggered = true
		for gate in gate_triggers:
			if gate.is_inside_tree():
				gate.get_node("GateAudio").play()
		spawn_enemy()
		gate_pos = gate_position.x
		await get_tree().create_timer(0.2).timeout
		(body.get_node("CameraPivot/Camera") as CameraShake).shake()


func _physics_process(delta: float) -> void:
	if !completed and triggered and gate_pos > gate_position.y:
		gate_pos = max(gate_pos - delta * 10, gate_position.y)
		for gate in gate_triggers:
			if gate.is_inside_tree():
				gate.position.y = gate_pos
	elif completed and gate_pos < gate_position.x:
		gate_pos = min(gate_pos + delta * 1, gate_position.x)
		for gate in gate_triggers:
			if gate.is_inside_tree():
				gate.position.y = gate_pos


func spawn_enemy():
	var enemy = total_enemies_to_spawn[0].instantiate()
	enemy.position = $EnemySpawnPoints.get_child(randi() % $EnemySpawnPoints.get_child_count()).position
	(enemy.get_node("Health") as Health).died.connect(on_enemy_died)
	add_child(enemy)
	total_enemies_to_spawn.remove_at(0)
	
	if total_enemies_to_spawn.size() > 0:
		await get_tree().create_timer(spawn_interval).timeout
		spawn_enemy()


func on_enemy_died():
	enemies_to_kill -= 1
	if enemies_to_kill == 0:
		await get_tree().create_timer(1).timeout
		completed = true
		room_completed.emit()
		
		for gate in gate_triggers:
			if gate.is_inside_tree():
				gate.get_node("GateAudio").stream = preload("res://sfx/props/iron_gates_retract.wav")
				gate.get_node("GateAudio").play()
