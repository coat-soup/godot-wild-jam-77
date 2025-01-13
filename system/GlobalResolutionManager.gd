extends Node

@onready var view_box: SubViewportContainer = $ViewBox

func _ready():
	view_box.scale = Vector2(3,3)
