extends Control

@onready var score_label: Label = $Label

func _ready() -> void:
	GameState.score = 0
	_update_score()

func _process(_delta: float) -> void:
	_update_score()

func _update_score() -> void:
	score_label.text = str(GameState.score)
