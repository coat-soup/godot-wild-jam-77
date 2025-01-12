extends Node3D

class_name Arms

signal hit_sword
signal swing_sword

@onready var ap: AnimationPlayer = $AnimationPlayer

@export var damage : int = 30

var blocking : bool = false
var swinging : bool = false

var swing_trigger : bool = false
var idle : bool = true

var timer : float = 0

var combo_interval = 1
var combo_window = 0.75
var can_swing = true

var to_damage : Array[Node3D]

func swing():
	if can_swing and (timer > 0 or idle):
		swing_sword.emit()
		swinging = true
		swing_trigger = true
		idle = false
		
		# bounce timer
		# timer = 0.5
		to_damage.clear()
		
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
		if !to_damage.has(body.owner):
			to_damage.append(body.owner)
			print("arms got sword hit")
			print("hit ", body.name)
			hit_sword.emit()
			
			var health = HierarchyUtil.get_child_of_type(body.owner, Health) as Health
			if health:
				health.take_damage(damage, self)

func _process(delta: float) -> void:
	if timer > 0:
		timer -= delta
		if timer <= 0:
			# bounce timer
			if swinging:
				pass
			else:
				if can_swing:
					can_swing = false
					idle = true
					timer = combo_interval
				else:
					can_swing = true


func _on_animation_tree_animation_started(_anim_name: StringName) -> void:
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
