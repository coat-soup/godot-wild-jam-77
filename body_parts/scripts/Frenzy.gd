extends BodyPart

@export var attack_speed_mul : float
@export var duration : float
@export var health_threshhold : float

func on_equip():
	player.health.took_damage.connect(on_damaged)
	

func on_drop(pos: Vector3):
	player.health.took_damage.disconnect(on_damaged)
	super.on_drop(pos)

func on_damaged(amount, _source):
	var real_thresh = player.health.max_health * health_threshhold
	if player.health.cur_health < real_thresh and player.health.cur_health + amount >= real_thresh:
		player.arms.set_attack_speed(player.arms.attack_speed * attack_speed_mul)
		await get_tree().create_timer(duration).timeout
		player.arms.set_attack_speed(player.arms.attack_speed / attack_speed_mul)
