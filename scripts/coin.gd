extends Area2D

func _on_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("player"):
		GameState.add_score()
		print("Coin collected! Score:", GameState.score)
	queue_free()