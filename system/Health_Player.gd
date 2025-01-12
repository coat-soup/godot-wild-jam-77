extends Health

@onready var arms: Arms = $"../CameraPivot/ArmsPivot/FirstPersonArms"

signal successful_block

func take_damage(amount : int, source : Node3D):
	if arms.blocking:
		print("ANGLE: ", rad_to_deg((-arms.global_basis.z).angle_to(source.global_position - arms.global_position)))
		if rad_to_deg((-arms.global_basis.z).angle_to(source.global_position - arms.global_position)) < 40:
			successful_block.emit()
			return
	super.take_damage(amount, source)
