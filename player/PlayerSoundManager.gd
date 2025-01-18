extends Node3D

@onready var footstep_audio: AudioStreamPlayer3D = $FootstepAudio
@onready var jumping_audio: AudioStreamPlayer3D = $JumpingAudio
@onready var sword_whoosh: AudioStreamPlayer3D = $SwordWhooshes
@onready var sword_clangs: AudioStreamPlayer3D = $SwordClangs
@onready var health_audio: AudioStreamPlayer3D = $HealthAudio

@onready var sword_bounce_sound = load("res://sfx/weapons/sword_bounce.wav")
@onready var sword_block_sound = load("res://sfx/weapons/sword_block.wav")
@onready var sword_hit_sound = load("res://sfx/weapons/sword_slice.wav")

@onready var damaged_sound = load("res://sfx/interactions/player_damaged.wav")
@onready var heal_sound = load("res://sfx/interactions/heal.wav")
@onready var no_stamina_sound = load("res://sfx/interactions/out_of_breath.wav")
@onready var death_sound = load("res://sfx/interactions/death.wav")

@onready var jump_land_sound = load("res://sfx/footsteps/jump-land.wav")
@onready var dash_sound = load("res://sfx/interactions/dash.wav")

var can_footstep : bool = false


func _on_player_bob_bottom() -> void:
	if can_footstep:
		footstep_audio.play()
		can_footstep = false


func _on_player_bob_top() -> void:
	can_footstep = true


func _on_first_person_arms_swing_sword() -> void:
	await get_tree().create_timer(0.1).timeout
	sword_whoosh.pitch_scale = randf_range(.8, 1)
	sword_whoosh.play()


func _on_first_person_arms_sword_bounce() -> void:
	sword_clangs.pitch_scale = randf_range(.8, 1.2)
	sword_clangs.stream = sword_bounce_sound
	sword_clangs.play()


func _on_player_jump_land() -> void:
	jumping_audio.pitch_scale = randf_range(.8, 1.2)
	jumping_audio.stream = jump_land_sound
	jumping_audio.play()


func _on_player_dash() -> void:
	jumping_audio.pitch_scale = randf_range(.8, 1.2)
	jumping_audio.stream = dash_sound
	jumping_audio.play()


func _on_health_successful_block(_damage) -> void:
	sword_clangs.pitch_scale = randf_range(.8, 1.2)
	sword_clangs.stream = sword_block_sound
	sword_clangs.play()


func _on_first_person_arms_sword_hit(_enemy) -> void:
	sword_clangs.pitch_scale = randf_range(.8, 1.2)
	sword_clangs.stream = sword_hit_sound
	sword_clangs.play()


func _on_health_took_damage(_amount, _source) -> void:
	health_audio.pitch_scale = randf_range(.9, 1)
	health_audio.stream = damaged_sound
	health_audio.play()


func _on_health_healed() -> void:
	health_audio.pitch_scale = 1
	health_audio.stream = heal_sound
	health_audio.play()


func _on_stamina_stamina_depleted() -> void:
	health_audio.pitch_scale = 1.1
	health_audio.stream = no_stamina_sound
	health_audio.play()


func _on_health_died() -> void:
	health_audio.pitch_scale = 1
	health_audio.stream = death_sound
	health_audio.play()
