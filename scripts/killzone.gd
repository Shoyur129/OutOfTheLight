extends Area2D

@onready var timer = $Timer

func _on_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("player"):
		_body.is_dead = true
		_body.velocity = Vector2.ZERO
		if _body.sprite.sprite_frames.has_animation("Die"):
			_body.sprite.play("Die")
		Engine.time_scale = 0.5
		timer.start()

func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
