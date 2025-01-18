extends BodyPart

@export var speed_burst_mul : float
@export var duration : float
@export var dash_distance_mul : float

func on_equip():
	player.dash_length *= dash_distance_mul
	player.dash.connect(on_dash)
	

func on_drop(pos: Vector3):
	player.dash.disconnect(on_dash)
	player.dash_length /= dash_distance_mul
	super.on_drop(pos)

func on_dash():
	player.speed *= speed_burst_mul
	await get_tree().create_timer(duration).timeout
	player.speed /= speed_burst_mul
