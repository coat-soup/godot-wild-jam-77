extends BodyPart

@export var stamina_regen_mul : float
@export var stamina_deplete_delay_mul : float

func on_equip():
	player.stamina.recharge_rate *= stamina_regen_mul
	player.stamina.depleted_recharge_delay *= stamina_deplete_delay_mul

func on_drop(pos: Vector3):
	player.stamina.recharge_rate /= stamina_regen_mul
	player.stamina.depleted_recharge_delay /= stamina_deplete_delay_mul
	
	super.on_drop(pos)
