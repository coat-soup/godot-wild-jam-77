extends Node3D

class_name EnemyModelInterface

@onready var animation_tree: AnimationTree = $AnimationTree

@export var attack_collider : Area3D
@export var attack_audio : Array[AudioStreamPlayer3D]
@export var attack_audio_delays : Array[float]
@onready var footsetp_audio: AudioStreamPlayer3D = $Footsetp_Audio

signal attack_collision

var enemy : Enemy

func _ready():
	enemy = get_owner() as Enemy
	attack_collider.body_entered.connect(on_trigger_body_entered)
	
func on_trigger_body_entered(body: Node3D):
	attack_collision.emit(body)

func play_footstep():
	footsetp_audio.pitch_scale = randf_range(.9, 1.1)
	footsetp_audio.play()

func play_attack_audio():
	if attack_audio_delays.size() > 0:
		await get_tree().create_timer(attack_audio_delays[0]).timeout
	for a in attack_audio:
		a.play()

func start_damage_window():
	enemy.damage_window_active = true

func end_damage_window():
	enemy.damage_window_active = false
