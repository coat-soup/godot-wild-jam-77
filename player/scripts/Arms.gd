extends Node3D

class_name Arms

signal sword_hit
signal sword_bounce
signal swing_sword

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var at: AnimationTree = $AnimationTree

@export var damage : int = 30

var blocking : bool = false
var swinging : bool = false

var swing_trigger : bool = false
var idle : bool = true

var timer : float = 0
var bounce_timer : float = 0

var combo_interval = 1
var combo_window = 0.75
var can_swing = true

var to_damage : Array[Node3D]

func swing():
	#at.set("parameters/BlendTree/TimeScale/scale", 1000)
	#print(at.get("parameters/BlendTree/TimeScale/scale"))
	#print(at.get("parameters/BlendTree/Animation"))
	#load("res://player/AttackAnimation").animation = "Block"
	
	if can_swing and (timer > 0 or idle):
		swing_sword.emit()
		swinging = true
		swing_trigger = true
		idle = false
		
		# bounce timer
		bounce_timer = 0.7
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

func bounce_sword():
	sword_bounce.emit()	
	var temp_rate = ap.speed_scale
	ap.speed_scale = 0
	
	#await get_tree().create_timer(1.0).timeout
	#ap.speed_scale = temp_rate
	reset_combo()


func _on_weapon_hitbox_body_entered(body: Node3D) -> void:
	if swinging:
		if !to_damage.has(body.owner):
			to_damage.append(body.owner)
			print("arms got sword hit")
			print("hit ", body.name)
			
			var health = HierarchyUtil.get_child_of_type(body.owner, Health) as Health
			if health:
				health.take_damage(damage, self)
				sword_hit.emit()
			else:
				if bounce_timer > 0:
					bounce_sword()

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
	if bounce_timer > 0:
		bounce_timer -= delta


func _on_animation_tree_animation_started(_anim_name: StringName) -> void:
	swing_trigger = false
	can_swing = false


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Swing1" or anim_name == "Swing2":
		timer = combo_window
		can_swing = true
		
	if anim_name == "Swing3":
		reset_combo()
		
	swinging = false

func reset_combo():
	print("Ending combo")
	can_swing = false
	timer = combo_interval
	idle = true
