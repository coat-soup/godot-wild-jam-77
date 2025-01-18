extends Interactable

var attuned = false

var hud : PlayerHUD

var to_complete_game = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hud = get_tree().get_first_node_in_group("HUD") as PlayerHUD
	tooltip = false

func interact():
	if to_complete_game:
		print("YOU WIN!!!!!!!!!!!!!!")
		hud.get_node("DeathText").text = "YOU WIN!!!!!!!!!!!!!!!!!!!!!!"
		hud.player.get_node("Health").take_damage(9999, self)
	elif attuned:
		hud.player.position = Vector3(0,-200,0)
		hud.loading_screen.show()
		($"../../.." as DungeonSpawner).generate()
		
		super.interact()


func _on_ritual_table_attuned() -> void:
	attuned = true
	tooltip = true
	to_complete_game = true
	for part in hud.menu.equipped_parts:
		if part == null or (part != null and !part.attuned):
			to_complete_game = false
	observe_message = "Proceed to next level" if !to_complete_game else "Complete game"
