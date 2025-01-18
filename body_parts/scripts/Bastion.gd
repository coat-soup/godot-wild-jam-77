extends BodyPart

@export var health_mul : float
@export var damage_mul : float

func on_equip():
	player.arms.damage *= damage_mul
	player.health.max_health *= health_mul
	player.health.cur_health *= health_mul

func on_drop(pos: Vector3):
	player.arms.damage /= damage_mul
	player.health.max_health /= health_mul
	player.health.cur_health /= health_mul
	
	super.on_drop(pos)
