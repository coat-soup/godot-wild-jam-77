extends BodyPart

@export var damage_mul : float
@export var attack_speed_mul : float
var cur_value = 0

func on_equip():
	player.arms.swing_sword.connect(reset)
	player.arms.sword_hit.connect(on_hit)
	player.arms.set_attack_speed(player.arms.attack_speed * attack_speed_mul)

func on_drop(pos: Vector3):
	player.arms.sword_hit.disconnect(on_hit)
	player.arms.set_attack_speed(player.arms.attack_speed / attack_speed_mul)
	
	super.on_drop(pos)

func on_hit(_enemy):
	player.arms.damage *= damage_mul
	cur_value += 1

func reset():
	for i in range(cur_value):
		player.arms.damage /= damage_mul
	cur_value = 0
