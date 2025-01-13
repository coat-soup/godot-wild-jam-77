extends Node

@onready var view_box: SubViewportContainer = $ViewBox
@onready var sub_viewport: SubViewport = $ViewBox/SubViewport
@onready var screen_res = get_viewport().size

func _ready():
	var scaling: Vector2 = screen_res / sub_viewport.size
	view_box.scale = Vector2(3,3)
	print(screen_res, " ", sub_viewport.size)
