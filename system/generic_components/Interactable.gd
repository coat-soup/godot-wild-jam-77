extends StaticBody3D

class_name Interactable

signal interacted

@export var observe_message : String

func interact():
	interacted.emit()
	print("INTERACTING")

func observe() -> String:
	return observe_message
