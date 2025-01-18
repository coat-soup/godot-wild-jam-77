extends BodyPart

@export_range(0, 1) var stun_chance : float
@export var stun_duration : float
var cur_value = 0

func on_equip():
	player.arms.sword_hit.connect(on_hit)

func on_drop(pos: Vector3):
	player.arms.sword_hit.disconnect(on_hit)
	
	super.on_drop(pos)

func on_hit(enemy):
	if randf() < stun_chance:
		enemy = enemy.get_owner() as Enemy
		if enemy:
			enemy.stun(stun_duration)
		else:
			print("not an enemy")
