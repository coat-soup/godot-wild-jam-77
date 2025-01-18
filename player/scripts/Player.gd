extends CharacterBody3D

class_name Player

signal dash
signal killed_enemy

@onready var arms: Node3D = $CameraPivot/ArmsPivot/FirstPersonArms
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera
@onready var stamina: Stamina = $Stamina
@onready var health: PlayerHealth = $Health

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var sensetivity = 0.005;

@export var dash_speed = 15
@export var dash_length = 0.2
@export var dash_cooldown = 1.5
var dash_cooldown_timer = 0
var dash_timer = 0
var dash_dir

#viewbob
const BOB_FREQ = 2.5
const BOB_AMP = 0.05
var t_bob : float = 0.0

signal bob_top
signal bob_bottom

var landing : bool
signal jump_start
signal jump_land

var HUD : PlayerHUD

var debug_mode = false

var interact_object


func _ready():
	HUD = get_tree().get_first_node_in_group("HUD")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and interact_object and !HUD.in_menu:
		interact_object.interact()
	
	if event.is_action_pressed("attack"):
		arms.swing()

	if event.is_action_released("block"):
		arms.end_block()
		
	if Input.is_key_pressed(KEY_SEMICOLON):
		debug_mode = !debug_mode
		if debug_mode:
			collision_shape_3d.disabled = true
		else:
			collision_shape_3d.disabled = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var sens_mul = 1.0 if !arms.swinging else 0.3
		rotate_y(-event.relative.x * sensetivity * sens_mul)
		camera_pivot.rotate_x(-event.relative.y * sensetivity * sens_mul)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	#arms_pivot.rotation = lerp(arms_pivot.rotation, camera_pivot.rotation, delta * (1 if arms.swinging else 20))
	
	try_interact()
	
	if Input.is_action_pressed("block"):
		arms.block()
	
	# Add the gravity.
	if not is_on_floor() and !debug_mode:
		velocity += get_gravity() * delta


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if debug_mode:
		velocity.y = (int(Input.is_key_pressed(KEY_SPACE)) - int(Input.is_key_pressed(KEY_CTRL))) * speed
	
			# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if stamina.cur_stamina > 0:
			if input_dir.y < 0 or input_dir == Vector2.ZERO:
				jump_start.emit()
				velocity.y = jump_velocity
			elif dash_cooldown_timer <= 0:
				dash.emit()
				dash_dir = direction
				dash_timer = dash_length
		else:
			stamina.alert_anim()
		
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
		
	if dash_timer > 0:
		dash_timer -= delta
		if dash_timer <= 0:
			dash_cooldown_timer = dash_cooldown
		velocity.x = lerp(velocity.x, dash_dir.x * dash_speed, delta * 10)
		velocity.z = lerp(velocity.z, dash_dir.z * dash_speed, delta * 10)
	elif is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 10)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 10)
		
		if landing:
			landing = false
			if velocity.y < 1:
				jump_land.emit()
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2)
		
		if !landing:
			landing = true

	#viewbob
	t_bob += delta * velocity.length() * float(is_on_floor())
	var b : float = bob_calc(t_bob)
	camera.transform.origin = Vector3(0, b, 0)
	
	#bob signals
	if b/BOB_AMP < 0.05:
		bob_bottom.emit()
	elif b/BOB_AMP > 0.95:
		bob_top.emit()

	move_and_slide()

func bob_calc(time : float) -> float:
	return BOB_AMP * sin(time * BOB_FREQ)


func try_interact():
	if not HUD:
		return # so it doesn't crash on testing
	
	if HUD.in_menu:
		interact_object = null
		return
		
	var space_state = get_world_3d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position + -camera.global_basis.z * 3, 2, [self])
	var result = space_state.intersect_ray(query)
	if result:
		interact_object = result.collider as Interactable
		if interact_object:
			HUD.set_interact_text(interact_object.observe())
		else:
			HUD.clear_interact_text()
	else:
		interact_object = null
		HUD.clear_interact_text()

func on_enemy_died():
	killed_enemy.emit()
