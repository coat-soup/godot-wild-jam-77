extends BodyPart

@export var damage_mul : float
@export var dash_stamina_mul : float

var active := false
var moving := false

func on_equip():
	player.stamina.dash_stamina *= dash_stamina_mul
	active = true

func on_drop(pos: Vector3):
	active = false
	player.stamina.dash_stamina /= dash_stamina_mul
	
	if !moving:
		player.arms.damage /= damage_mul
	
	super.on_drop(pos)

func _process(delta: float) -> void:
	if active:
		#print(player.velocity)
		if moving:
			if player.velocity.length() < 0.4:
				moving = false
				player.arms.damage *= damage_mul
				print("stopped moving")
		else:
			if player.velocity.length() > 0.4:
				moving = true
				player.arms.damage /= damage_mul
				print("started moving")
