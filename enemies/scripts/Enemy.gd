extends CharacterBody3D

class_name Enemy

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

@export var speed: float = 3.0
@export var turn_rate: float = 2.0
@export var damage: int = 20

@export var attack_windup_time: float = 0.7

@onready var player: Node3D

var model_interface : EnemyModelInterface

var anim_tree : AnimationTree

var attack_trigger: bool = false

enum EnemyState {idle, walking, attacking, nothing_lol = -1, }
var state : EnemyState = EnemyState.idle


func _ready() -> void:
	model_interface = get_child(0) as EnemyModelInterface
	
	model_interface.attack_collision.connect(on_attack_collision)
	
	anim_tree = model_interface.animation_tree as AnimationTree
	if not anim_tree:
		push_error("Enemy ", self.name, " could not find animation tree.")
	else:
		anim_tree.advance_expression_base_node = "../.."
		print("Base of ", self.name, " is ", anim_tree.get_node("../.."))
		anim_tree.animation_finished.connect(on_anim_finished)
		anim_tree.animation_started.connect(on_anim_started)
		
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_error("Enemy could not find player")


func set_target(pos: Vector3):
	nav_agent.target_position = pos


func _physics_process(delta: float) -> void:
	if state == EnemyState.idle:
		state = EnemyState.walking
	
	if state == EnemyState.walking:
		set_target(player.global_position)
		
		var cur_pos = global_transform.origin
		var next_pos = nav_agent.get_next_path_position()
		var new_vel = (next_pos - cur_pos).normalized() * speed
		
		nav_agent.velocity = new_vel
		
		var angle = rad_to_deg((global_basis.z).signed_angle_to(next_pos - global_position, Vector3.UP))
		if abs(angle) > 2:
			rotation.y = lerp_angle(rotation.y, rotation.y + deg_to_rad(angle), delta * turn_rate)
			#rotate_y(turn_rate * delta * (1 if angle > 0 else -1))
		
		if global_position.distance_to(nav_agent.target_position) <=2:
			nav_agent.velocity = Vector3.ZERO
			attack_trigger = true
			await change_state_delay(EnemyState.attacking, attack_windup_time)
			model_interface.play_attack_audio()


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()


func on_attack_collision(body: Node3D):
	if state == EnemyState.attacking:
		print("attack hit ", body.name)
		if body == player:
			print("hit player properly")
			var health = body.get_node("Health") as Health
			if health:
				health.take_damage(damage, model_interface.attack_collider)
		

func on_anim_started(anim_name):
	if anim_name == "Attack":
		attack_trigger = false


func on_anim_finished(anim_name):
	if anim_name == "Attack":
		print("finished attacke")
		change_state_delay(EnemyState.idle, 0.5)


func change_state_delay(new_state, delay_time: float, intermediate_null: bool = true):
	if intermediate_null:
		state = EnemyState.nothing_lol
	await get_tree().create_timer(delay_time).timeout
	state = new_state
