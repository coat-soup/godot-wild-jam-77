extends Node

@onready var circle_001: MeshInstance3D = $"../Armature/Skeleton3D/Circle_001/Circle_001"
@onready var circle_006: MeshInstance3D = $"../Armature/Skeleton3D/Circle_006/Circle_006"
@onready var whirr_audio: AudioStreamPlayer3D = $"../Armature/Skeleton3D/Circle_006/Area3D/WhirrAudio"

@export var spin_speed : float = 1000
var cur_spin_speed : float

var enemy: Enemy

var override_spin_start: float = 0

func _ready():
	enemy = get_parent().get_parent() as Enemy
	if !enemy:
		push_error("spinny blade thing didn't find enemy")

func _physics_process(delta: float) -> void:
	if enemy.attack_trigger:
		print("STARTINNGGG")
		override_spin_start = 1
	
	var is_attacking = enemy.state == enemy.EnemyState.attacking
	if override_spin_start > 0 or abs(cur_spin_speed) > 1 or is_attacking:
		override_spin_start -= delta
		cur_spin_speed = lerp(cur_spin_speed, spin_speed * (1 if is_attacking or override_spin_start > 0 else 0), 2 * delta)
		
		whirr_audio.volume_db = lerp(-100, 0, cur_spin_speed/spin_speed)

		circle_001.rotate_y(deg_to_rad(cur_spin_speed * delta))
		circle_006.rotate_y(deg_to_rad(cur_spin_speed * delta))
