extends Node

func _ready():
	print ("Player health: ", GameState.playerhealth)

func update_player_health(amount: int) -> void:
	GameState.playerhealth = amount
	print("Player health updated to: ", GameState.playerhealth)

func _process(_delta: float) -> void:
	pass
