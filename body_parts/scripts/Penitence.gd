extends BodyPart

@export var health_mul : float
@export var damage_to_stamina_mul : float

func on_equip():
	player.health.took_damage.connect(on_take_damage)
	player.health.max_health *= health_mul
	player.health.cur_health *= health_mul

func on_drop(pos: Vector3):
	player.health.took_damage.disconnect(on_take_damage)
	player.health.max_health /= health_mul
	player.health.cur_health /= health_mul
	
	super.on_drop(pos)

func on_take_damage(amount, source):
	player.stamina.add_stamina(amount * damage_to_stamina_mul)
