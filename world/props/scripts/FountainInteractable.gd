extends Interactable

func interact():
	if active:
		var health = get_tree().get_first_node_in_group("player").get_node("Health") as PlayerHealth
		health.heal(health.fountain_health_percent * health.max_health)
		active = false
