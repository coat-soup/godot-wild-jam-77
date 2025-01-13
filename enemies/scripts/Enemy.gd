extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

@export var speed: float = 3.0

@onready var player: Node3D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_error("Enemy could not find player")

func set_target(position: Vector3):
	nav_agent.target_position = position

func _physics_process(delta: float) -> void:
	set_target(player.position)
	
	var cur_pos = global_transform.origin
	var next_pos = nav_agent.get_next_path_position()
	var new_vel = (next_pos - cur_pos).normalized() * speed
	
	nav_agent.velocity = new_vel
	


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()
