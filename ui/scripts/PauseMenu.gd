extends Control

var hud: PlayerHUD

func _ready():
	hud = $".." as PlayerHUD
	if !hud:
		push_error("Pause menu could not find HUD")



func _on_resume_pressed() -> void:
	hud.toggle_pause()


func _on_restart_pressed() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()
