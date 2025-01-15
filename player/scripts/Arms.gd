extends Node3D

class_name Arms

signal sword_hit
signal sword_bounce
signal swing_sword

@onready var weapon_hitbox: Area3D = $Armature/Skeleton3D/SwordHilt/WeaponHitbox
var stamina : Stamina

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var at: AnimationTree = $AnimationTree

@export var damage : int = 30
@export var attack_speed : float = 1

var blocking : bool = false
var swinging : bool = false

var swing_trigger : bool = false
var idle : bool = true

var timer : float = 0
var bounce_timer : float = 0
var bounce_time : float = 10

var combo_interval = 1
var combo_window = 0.75
var can_swing = true

var to_damage : Array[Node3D]

func _ready():
	stamina = get_owner().get_node("Stamina") as Stamina
	if not stamina:
		push_error("Arms could not find stamina")
	stamina.stamina_depleted.connect(end_block)
		
	set_attack_speed(attack_speed)

func swing():
	if can_swing and (timer > 0 or idle):
		if stamina.cur_stamina <= 0:
			stamina.alert_anim()
			return
			
		swing_sword.emit()
		swinging = true
		swing_trigger = true
		idle = false
		can_swing = false
		
		# damage everything already inside trigger
		for body in weapon_hitbox.get_overlapping_bodies():
			_on_weapon_hitbox_body_entered(body)
		
		# bounce timer
		bounce_timer = bounce_time
		to_damage.clear()


func set_attack_speed(speed: float, rel: bool = false):
	attack_speed = speed if !rel else attack_speed * speed
	at.set("parameters/BlendTree 2/TimeScale/scale", attack_speed)


func block():
	if !swinging:
		if stamina.cur_stamina <= 0:
			stamina.alert_anim()
			return
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
	swinging = false
	
	var temp_scale = at.get("parameters/BlendTree 2/TimeScale/scale")
	at.set("parameters/BlendTree 2/TimeScale/scale", -0.5)
	await get_tree().create_timer(0.3).timeout
	at.set("parameters/BlendTree 2/TimeScale/scale", temp_scale)
	idle = true
	
	reset_combo()

# to make sure stuff takes damages that starts inside the hitbox
func _on_weapon_hitbox_body_exited(body: Node3D) -> void:
	_on_weapon_hitbox_body_entered(body)

func _on_weapon_hitbox_body_entered(body: Node3D) -> void:
	if swinging:
		body = body if is_instance_of(body, CharacterBody3D) else body.owner
		if body.name != "Player" and !to_damage.has(body):
			to_damage.append(body)
			print("arms got sword hit")
			print("hit ", body.name)
			
			var health = HierarchyUtil.get_child_of_type(body, Health) as Health
			if health:
				health.take_damage(damage, self)
				sword_hit.emit()
			else:
				if bounce_timer > 0:
					bounce_sword()
					return


func _process(delta: float) -> void:
	if timer > 0:
		timer -= delta
		if timer <= 0:
			if can_swing:
				reset_combo()
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
	timer = combo_interval/attack_speed
	idle = true
