extends BodyPart

@export var fountain_health_mul : float
@export var health_regen_speed : float
@export var health_threshhold : float
@export var damage_delay : float

var active := false
var suppressed := 0.0

func on_equip():
	active = true
	player.health.took_damage.connect(suppress)
	player.health.fountain_health *= fountain_health_mul

func on_drop(pos: Vector3):
	active = false
	player.health.took_damage.disconnect(suppress)
	player.health.fountain_health /= fountain_health_mul
	
	super.on_drop(pos)

func _process(delta: float) -> void:
	if suppressed > 0:
		suppressed -= delta
	if active and suppressed <= 0 and player.health.cur_health < player.health.max_health * health_threshhold:
		player.health.cur_health += delta * health_regen_speed #add manually to bypass on_heal
		player.HUD.update_health_bar()

func suppress(_amount, _source):
	suppressed = damage_delay
