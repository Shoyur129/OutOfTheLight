extends Area2D

@export var damage_amount: int = 1
@export var damage_delay: float = .75

var player_ref: Node = null
var damage_cooldown: float = 0.0

func _physics_process(delta: float) -> void:
	if player_ref == null:
		return
	damage_cooldown -= delta
	if damage_cooldown <= 0:
		if player_ref.has_method("take_damage"):
			player_ref.take_damage(damage_amount)
			print("Light damaged player")
		else:
			print("Player missing take_damage function")
		damage_cooldown = damage_delay

func _on_body_entered(body: Node) -> void:
	print("Light touched: ", body.name)
	if body.name == "Player" or body.is_in_group("player"):
		player_ref = body
		damage_cooldown = damage_delay

func _on_body_exited(body: Node) -> void:
	if body == player_ref:
		player_ref = null


func _on_damage_timer_timeout() -> void:
	pass # Replace with function body.
