extends BodyPart

@export var block_hold_stamina_mul : float

func on_equip():
	player.arms.on_attempt_block.connect(on_attempt_block)
	player.stamina.block_stamina *= block_hold_stamina_mul

func on_drop(pos: Vector3):
	player.arms.on_attempt_block.disconnect(on_attempt_block)
	player.stamina.block_stamina /= block_hold_stamina_mul
	
	super.on_drop(pos)

func on_attempt_block():
	if player.arms.swinging:
		print("TRIED INTRERUPTING")
		player.arms.swinging = false
		player.arms.block()
