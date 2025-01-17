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
	set_display(part)


func set_display(part: BodyPart):
	display_icon.texture = part.icon
	$MenuBackground/DisplayBackground/TitleText.text = part.item_name
	$MenuBackground/DisplayBackground/InfoText.text = part.item_description
	display_valid_slots()


func clear_display():
	selected_slot = -1
	display_icon.texture = null
	title_text.text = ""
	info_text.text = ""
	
	evaluate_swap_button()
	display_valid_slots()


func slot_pressed(index: int):
	selected_slot = index
	evaluate_swap_button()


func evaluate_swap_button():
	if selected_slot >= 0 and picking_part and get_slot_type(selected_slot) != picking_part.body_slot:
		swap_button.disabled = true
		swap_button.get_child(0).text = "WRONG SLOT"
	elif selected_slot >= 0 and equipped_parts[selected_slot] and picking_part:
		swap_button.disabled = false
		swap_button.get_child(0).text = "SWAP"
	elif selected_slot >= 0 and equipped_parts[selected_slot] and !picking_part:
		swap_button.disabled = false
		set_display(equipped_parts[selected_slot])
		swap_button.get_child(0).text = "DROP"
	elif selected_slot >= 0 and picking_part:
		swap_button.disabled = false
		swap_button.get_child(0).text = "EQUIP"
	else:
		swap_button.disabled = true
		swap_button.get_child(0).text = "NO SELECTION"
		


func swap_pressed():
	# if swapping
	if picking_part != null and selected_slot >= 0:
		if get_slot_type(selected_slot) != picking_part.body_slot:
			ui.show_prompt("This item can only go in a " + BodyPart.BodySlotType.keys()[picking_part.body_slot] + " slot.")
			return
		
		var old_part: BodyPart = null
		
		old_part = equipped_parts[selected_slot]
		drop_part(selected_slot)
		equip_part(picking_part, selected_slot)
		
		picking_part = null
	
		if old_part:
			pick_part(old_part)
			print("repicking ", old_part)
		else:
			clear_display()
	elif picking_part == null and selected_slot >= 0:
		drop_part(selected_slot)
		clear_display()


func drop_part(index: int):
	if equipped_parts[index]:
		equipped_parts[index].on_drop(ui.player.global_position)
		equipped_parts[index].global_position = ui.player.global_position
		get_icon(index).texture = null
		equipped_parts[index] = null


func equip_part(part: BodyPart, index:int):
	if equipped_parts[index] != null:
		drop_part(index)
	get_icon(index).texture = part.icon
	equipped_parts[index] = part
	
	part.global_position = Vector3(0,-100,0)
	
	part.on_equip()


func get_icon(index: int) -> TextureRect:
	if index < 0 or index > 6:
		push_error("Invalid icon index")
		return null
	return slots_holder.get_child(index).get_child(0) as TextureRect


func display_valid_slots():
	for i in range(7):
		if picking_part and get_slot_type(i) == picking_part.body_slot:
			(slots_holder.get_child(i) as Button).add_theme_stylebox_override("normal", preload("res://ui/style_box_valid_slot.tres"))
			(slots_holder.get_child(i) as Button).add_theme_stylebox_override("hover", preload("res://ui/style_box_valid_slot_hover.tres"))
		else:
			(slots_holder.get_child(i) as Button).remove_theme_stylebox_override("normal")
			(slots_holder.get_child(i) as Button).remove_theme_stylebox_override("hover")
			


static func get_slot_type(index: int):
	match index:
		0: return BodyPart.BodySlotType.FACE
		1: return BodyPart.BodySlotType.HEART
		2: return BodyPart.BodySlotType.LUNGS
		3,4: return BodyPart.BodySlotType.ARM
		5,6: return BodyPart.BodySlotType.LEG
		_: return -1
