extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

@onready var trigger_sound = load("res://sfx/weapons/spike_trap_trigger.wav")
@onready var retract_sound = load("res://sfx/weapons/spike_trap_retract.wav")

var bloody_mat = preload("res://world/props/materials/spiketrap_bloody_mat.tres")

var armed : bool = true

@export var damage : int = 30


func _on_area_3d_body_entered(body: Node3D) -> void:
	if armed:
		if is_instance_of(body, CharacterBody3D):
			var health = HierarchyUtil.get_child_of_type(body, Health) as Health
			health.take_damage(damage, self)
			animation_player.play("Trigger")
			audio.stream = trigger_sound
			audio.play()
			for mesh in $SpikeTrap.get_children():
				mesh = mesh as MeshInstance3D
				mesh.set_surface_override_material(0, bloody_mat)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Trigger":
		armed = false
		await get_tree().create_timer(1.0).timeout
		animation_player.play("Retract")
		audio.stream = retract_sound
		audio.play()
	elif anim_name == "Retract":
		armed = true
