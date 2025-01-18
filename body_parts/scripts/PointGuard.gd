extends BodyPart

@export var block_angle_mul : float
@export var block_hold_stamina_mul : float

func on_equip():
	player.health.block_angle *= block_angle_mul
	player.stamina.block_stamina *= block_hold_stamina_mul

func on_drop(pos: Vector3):
	player.health.block_angle /= block_angle_mul
	player.stamina.block_stamina /= block_hold_stamina_mul
	
	super.on_drop(pos)
