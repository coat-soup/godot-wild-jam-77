extends Health

class_name PlayerHealth

@onready var arms: Arms = $"../CameraPivot/ArmsPivot/FirstPersonArms"
@onready var camera: CameraShake = $"../CameraPivot/Camera"

@export var fountain_health_percent := 0.7

@export var block_angle := 70.0

signal successful_block

@export var immune_duration := 1.5
var immune_timer = 0.0

func take_damage(amount : float, source : Node3D):
	if immune_timer > 0:
		print("immune to damage from block")
		return
	if arms.blocking:
		print("ANGLE: ", rad_to_deg((-arms.global_basis.z).angle_to(source.global_position - arms.global_position)))
		if rad_to_deg((-arms.global_basis.z).angle_to(source.global_position - arms.global_position)) < block_angle:
			successful_block.emit(amount)
			camera.shake(5)
			immune_timer = immune_duration
			return
	camera.shake(20.0)
	super.take_damage(amount, source)

func die():
	died.emit()

func _process(delta: float) -> void:
	if immune_timer > 0:
		immune_timer -= delta
