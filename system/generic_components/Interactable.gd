extends StaticBody3D

class_name Interactable

signal interacted

var active := true

var tooltip := true

@export var observe_message : String

func interact():
	if active:
		interacted.emit()
		print("INTERACTING")

func observe() -> String:
	if active:
		return observe_message
	else:
		return ""
