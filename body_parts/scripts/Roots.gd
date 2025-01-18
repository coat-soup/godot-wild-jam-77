extends BodyPart

@export var stamina_regen_delay_mul : float
@export var stamina_regen_mul : float

func on_equip():
	player.stamina.recharge_delay *= stamina_regen_delay_mul
	player.stamina.recharge_rate *= stamina_regen_mul

func on_drop(pos: Vector3):
	player.stamina.recharge_delay /= stamina_regen_delay_mul
	player.stamina.recharge_rate /= stamina_regen_mul
	
	super.on_drop(pos)
