extends Node3D

class_name EnemyModelInterface

@onready var animation_tree: AnimationTree = $AnimationTree

@export var attack_collider : Area3D

signal attack_collision

func _ready():
	attack_collider.body_entered.connect(on_trigger_body_entered)
	
func on_trigger_body_entered(body: Node3D):
	attack_collision.emit(body)
