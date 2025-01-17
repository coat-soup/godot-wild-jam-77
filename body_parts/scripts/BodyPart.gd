extends Node3D

class_name BodyPart
enum BodySlotType {FACE, LUNGS, HEART, ARM, LEG}

@export var item_name : String
@export_multiline var item_description: String
@export var body_slot : BodySlotType
@export var icon : Texture

var start_pos : Vector3
var hover_pos := 0.0

var menu : Menu

var player : Player


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	start_pos = position
	
	menu = get_tree().get_first_node_in_group("HUD").get_node("Menu") as Menu
	
	var hitbox = get_node("StaticBody3D") as Interactable
	if hitbox:
		hitbox.observe_message = item_name
		hitbox.interacted.connect(try_equip)


func _physics_process(delta: float) -> void:
	rotation.y += delta * 0.7
	
	hover_pos += delta * 0.8
	var amplitude = 0.2
	position.y = start_pos.y + sin(hover_pos) * amplitude + amplitude


func try_equip():
	menu.pick_part(self)


func on_equip():
	pass


func on_drop(pos: Vector3):
	start_pos = pos
	start_pos.y -= 1
	pass
