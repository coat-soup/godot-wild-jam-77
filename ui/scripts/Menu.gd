extends Control

class_name Menu

@onready var ui: PlayerHUD = $".."
@onready var swap_button: Button = $MenuBackground/DisplayBackground/SwapButton
@onready var slots_holder: ColorRect = $MenuBackground/SlotsBackground

@onready var display_icon: TextureRect = $MenuBackground/DisplayBackground/DisplayIcon
@onready var title_text: Label = $MenuBackground/DisplayBackground/TitleText
@onready var info_text: Label = $MenuBackground/DisplayBackground/InfoText

@export var slot_color : Color
@export var valid_slot_color : Color

var picking_part : BodyPart
var selected_slot : int = -1

var equipped_parts : Array[BodyPart] = [null, null, null, null, null, null, null]

func _ready():
	swap_button.pressed.connect(swap_pressed)
	for button in slots_holder.get_children():
		(button as Button).pressed.connect(slot_pressed.bind(button.get_index()))

func pick_part(part: BodyPart):
	picking_part = part
	if !ui.in_menu:
		ui.toggle_menu()
	display_icon.texture = part.icon
	$MenuBackground/DisplayBackground/TitleText.text = part.item_name
	display_valid_slots()

func clear_display():
	selected_slot = -1
	display_icon.texture = null
	title_text.text = ""
	info_text.text = ""
	
	display_valid_slots()

func slot_pressed(index: int):
	print("pressed ", index)
	selected_slot = index

func swap_pressed():
	var old_part: BodyPart = null
	if picking_part != null and selected_slot >= 0:
		old_part = equipped_parts[selected_slot]
		drop_part(selected_slot)
		equip_part(picking_part, selected_slot)
	picking_part = null
	
	if old_part:
		pick_part(old_part)
		print("repicking ", old_part)
	else:
		clear_display()

func drop_part(index: int):
	if equipped_parts[index]:
		get_icon(index).texture = null
		equipped_parts[index] = null
	
func equip_part(part: BodyPart, index:int):
	if equipped_parts[index] != null:
		drop_part(index)
	get_icon(index).texture = part.icon
	equipped_parts[index] = part

func get_icon(index: int) -> TextureRect:
	if index < 0 or index > 6:
		push_error("Invalid icon index")
		return null
	return slots_holder.get_child(index).get_child(0) as TextureRect


func display_valid_slots():
	for i in range(7):
		var color = Color(randf(), randf(), randf())
		(slots_holder.get_child(i) as Button).add_theme_stylebox_override("normal", preload("res://ui/style_box_valid_slot.tres"))
		#return
		if picking_part:
			print("slot type ", get_slot_type(i), " part type: ", picking_part.body_slot)
		if picking_part and get_slot_type(i) == picking_part.body_slot:
			color = valid_slot_color
			print("setting color")
		((slots_holder.get_child(i) as Button).get_theme_stylebox("normal") as StyleBoxFlat).bg_color = color
			


static func get_slot_type(index: int):
	match index:
		0: return BodyPart.BodySlotType.FACE
		1: return BodyPart.BodySlotType.HEART
		2: return BodyPart.BodySlotType.LUNGS
		3,4: return BodyPart.BodySlotType.ARM
		5,6: return BodyPart.BodySlotType.LEG
		_: return -1
