extends Node3D

signal hit_sword
signal swing_sword

var blocking : bool = false
var swinging : bool = false

var swing_trigger : bool = false
var idle : bool = true

var timer : float = 0

var combo_interval = 1
var combo_window = 0.5
var can_swing = true

@onready var ap: AnimationPlayer = $AnimationPlayer


func swing():
	if can_swing and (timer > 0 or idle):
		swing_sword.emit()
		swinging = true
		swing_trigger = true
		idle = false
		
func block():
	if !swinging:
		blocking = true
		can_swing = false
		swinging = false
	
func end_block():
	blocking = false
	can_swing = true
	idle = true
	swinging = false

func _on_weapon_hitbox_body_entered(body: Node3D) -> void:
	if swinging:
		print("arms got sword hit")
		print("hit ", body.name)
		hit_sword.emit()
		can_swing = false

func _process(delta: float) -> void:
	if timer > 0:
		timer -= delta
		if timer <= 0:
			if can_swing:
				can_swing = false
				idle = true
				timer = combo_interval
			else:
				can_swing = true


func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	swing_trigger = false
	can_swing = false


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Swing1" or anim_name == "Swing2":
		timer = combo_window
		can_swing = true
		
	if anim_name == "Swing3":
		print("Ending combo")
		can_swing = false
		timer = combo_interval
		idle = true
		
	swinging = false
