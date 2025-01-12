extends Node3D

@onready var footstep_audio: AudioStreamPlayer3D = $FootstepAudio
@onready var sword_audio: AudioStreamPlayer3D = $SwordAudio
@onready var jumping_audio: AudioStreamPlayer3D = $JumpingAudio


var can_footstep : bool = false

func _on_player_bob_bottom() -> void:
	if can_footstep:
		footstep_audio.play()
		can_footstep = false


func _on_player_bob_top() -> void:
	can_footstep = true


func _on_first_person_arms_swing_sword() -> void:
	await get_tree().create_timer(0.1).timeout
	sword_audio.pitch_scale = randf_range(.8, 1)
	sword_audio.play()


func _on_player_jump_land() -> void:
	jumping_audio.pitch_scale = randf_range(.8, 1.2)
	jumping_audio.play()
