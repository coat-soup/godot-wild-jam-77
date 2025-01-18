extends BodyPart

@export var dash_distance_mul : float
@export var dash_cooldown_mul : float
@export var dash_stamina_mul : float

func on_equip():
	player.dash_length *= dash_distance_mul
	player.dash_cooldown *= dash_cooldown_mul
	player.stamina.dash_stamina *= dash_stamina_mul

func on_drop(pos: Vector3):
	player.dash_length /= dash_distance_mul
	player.dash_cooldown /= dash_cooldown_mul
	player.stamina.dash_stamina /= dash_stamina_mul
	
	super.on_drop(pos)
