extends Health

class_name PlayerHealth

@onready var arms: Arms = $"../CameraPivot/ArmsPivot/FirstPersonArms"
@onready var camera: CameraShake = $"../CameraPivot/Camera"

signal successful_block

func take_damage(amount : int, source : Node3D):
	if arms.blocking:
		print("ANGLE: ", rad_to_deg((-arms.global_basis.z).angle_to(source.global_position - arms.global_position)))
		if rad_to_deg((-arms.global_basis.z).angle_to(source.global_position - arms.global_position)) < 45:
			successful_block.emit(amount)
			camera.shake(5)
			return
	camera.shake(20.0)
	super.take_damage(amount, source)

func die():
	died.emit()
