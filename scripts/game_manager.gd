extends Node

func _ready():
	print (GameState.playerhealth)

func update_playerhealth(amount: int):
	GameState.playerhealth += amount
	print("Player health: ", GameState.playerhealth)

func _process(_delta: float) -> void:
	pass
