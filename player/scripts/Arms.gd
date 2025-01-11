extends Node3D

signal hit_sword
signal swing_sword

var swinging : bool = false


func _on_weapon_hitbox_body_entered(body: Node3D) -> void:
	if swinging:
		print("arms got sword hit")
		print("hit ", body.name)
		hit_sword.emit()

func swing():
	swing_sword.emit()
	swinging = true
	$AnimationPlayer.speed_scale = 2
	$AnimationPlayer.play("Swing")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "Reset":
		swinging = false
		print("swing done")
		$AnimationPlayer.play("Reset")
