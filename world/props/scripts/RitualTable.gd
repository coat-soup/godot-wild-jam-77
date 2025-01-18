extends Node3D

class_name RitualTable

signal attuned

var bloody_mat = preload("res://world/props/materials/ritualtable_bloody_mat.tres")

var menu
var used := false


func _ready() -> void:
	menu = get_tree().get_first_node_in_group("HUD").get_node("Menu") as Menu

func disactivate():
	attuned.emit()
	$AudioStreamPlayer3D.play()
	used = true
	$TriggerArea.active = false
	for mesh in $TableCut.get_children():
		mesh = mesh as MeshInstance3D
		mesh.set_surface_override_material(0, bloody_mat)


func _on_trigger_area_interacted() -> void:
	if !used:
		menu.try_attunement(self)
