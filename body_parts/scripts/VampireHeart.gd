extends BodyPart

@export var health_mul : float
@export var health_percent_on_kill : float

func on_equip():
	player.killed_enemy.connect(on_killed)
	player.health.max_health *= health_mul
	player.health.cur_health *= health_mul

func on_drop(pos: Vector3):
	player.killed_enemy.disconnect(on_killed)
	player.health.max_health /= health_mul
	player.health.cur_health /= health_mul
	
	super.on_drop(pos)

func on_killed():
	player.health.heal(player.health.max_health * health_percent_on_kill)
