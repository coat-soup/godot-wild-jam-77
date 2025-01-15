extends Camera3D

class_name CameraShake

@export var shake_fade: float = 5.0

var rng = RandomNumberGenerator.new()

var shake_strength: float = 0.0

func shake(strength: float = 20.0):
	shake_strength = strength/100
	
func _physics_process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		
		var offset = random_offset()
		h_offset = offset.x
		v_offset = offset.y
		
func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
