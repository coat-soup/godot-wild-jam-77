extends Node3D

func _ready():
	(get_parent().get_parent() as DungeonRoom).room_completed.connect(spawn_part)
	
func spawn_part():
	print("spawning part")
	# this is so fucking stupid
	var part = [
preload("res://body_parts/scenes/bastion.tscn"),
preload("res://body_parts/scenes/clockwork_core.tscn"),
preload("res://body_parts/scenes/copper_boiler.tscn"),
preload("res://body_parts/scenes/domino_savant.tscn"),
preload("res://body_parts/scenes/ear_mass.tscn"),
preload("res://body_parts/scenes/frenzy.tscn"),
preload("res://body_parts/scenes/goat_leg.tscn"),
preload("res://body_parts/scenes/jitterbug.tscn"),
preload("res://body_parts/scenes/lightning_infused.tscn"),
#preload("res://body_parts/scenes/loaded_shot.tscn"),
preload("res://body_parts/scenes/lost_love.tscn"),
preload("res://body_parts/scenes/penitence.tscn"),
preload("res://body_parts/scenes/point_guard.tscn"),
preload("res://body_parts/scenes/pulleys.tscn"),
preload("res://body_parts/scenes/restful_lead.tscn"),
preload("res://body_parts/scenes/roots.tscn"),
#preload("res://body_parts/scenes/springjack.tscn"),
preload("res://body_parts/scenes/sprinter.tscn"),
preload("res://body_parts/scenes/stone_eye.tscn"),
preload("res://body_parts/scenes/sword_arm.tscn"),
preload("res://body_parts/scenes/vampire_heart.tscn"),
		
	].pick_random().instantiate()
	
	$SpawnPoint.add_child(part)
