extends Node

class_name Stamina

signal stamina_changed
signal stamina_depleted
signal alert_depleted

@onready var player: Player = $".."
@onready var arms: Arms = $"../CameraPivot/ArmsPivot/FirstPersonArms"
@onready var health: PlayerHealth = $"../Health"

@export var max_stamina : float = 100.0
var cur_stamina : float
@export var recharge_rate : float = 10

@export var swing_stamina : float = 15
@export var block_stamina : float = 7
@export var dash_stamina : float = 15

@export var recharge_delay : float = 1
@export var depleted_recharge_delay: float = 3
var recharge_delay_timer : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cur_stamina = max_stamina
	arms.swing_sword.connect(on_swing)
	health.successful_block.connect(on_block)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if recharge_delay_timer <= 0 and cur_stamina < max_stamina:
		cur_stamina += recharge_rate * delta
		stamina_changed.emit()
	elif recharge_delay_timer > 0:
		recharge_delay_timer -= delta
	
	if arms.blocking:
		drain_stamina(block_stamina * delta)


func on_swing():
	drain_stamina(swing_stamina)

func on_block(damage):
	drain_stamina(damage/1.5)

func drain_stamina(amount: float):
	recharge_delay_timer = recharge_delay
	
	cur_stamina -= amount
	stamina_changed.emit()

	if cur_stamina <= 0:
		recharge_delay_timer = depleted_recharge_delay
		cur_stamina = 0
		stamina_depleted.emit()
		alert_depleted.emit()

func alert_anim():
	alert_depleted.emit()
