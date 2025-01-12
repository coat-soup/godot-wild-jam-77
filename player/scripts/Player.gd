extends CharacterBody3D

@onready var arms: Node3D = $CameraPivot/FirstPersonArms

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSETIVITY = 0.005;

#viewbob
const BOB_FREQ = 2.5
const BOB_AMP = 0.05
var t_bob : float = 0.0

signal bob_top
signal bob_bottom

var landing : bool
signal jump_start
signal jump_land

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
		if event.is_action_pressed("quit"):
			get_tree().quit()
		if event.is_action_pressed("attack"):
			arms.swing()

		if event.is_action_released("block"):
			arms.end_block()
			

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSETIVITY)
		camera_pivot.rotate_x(-event.relative.y * SENSETIVITY)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("block"):
		arms.block()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump_start.emit()
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 10)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 10)
		
		if landing:
			landing = false
			if velocity.y < 1:
				jump_land.emit()
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 2)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 2)
		
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
