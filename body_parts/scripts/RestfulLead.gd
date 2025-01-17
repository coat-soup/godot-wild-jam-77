extends BodyPart

@export var damage_mul : float
@export var attack_speed_mul : float

func on_equip():
	player.arms.damage *= damage_mul
	player.arms.set_attack_speed(player.arms.attack_speed * attack_speed_mul)

func on_drop(pos: Vector3):
	player.arms.damage /= damage_mul
	player.arms.set_attack_speed(player.arms.attack_speed / attack_speed_mul)
	
	super.on_drop(pos)
