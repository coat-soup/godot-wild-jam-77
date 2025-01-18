extends BodyPart

@export var damage_mul : float
@export var attack_stamina_mul : float

func on_equip():
	player.arms.damage *= damage_mul
	player.stamina.swing_stamina *= attack_stamina_mul	

func on_drop(pos: Vector3):
	player.arms.damage /= damage_mul
	player.stamina.swing_stamina /= attack_stamina_mul
	
	super.on_drop(pos)
