extends Area2D

@onready var timer = $Timer

func _on_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("player"):
		_body.is_dead = true
		_body.velocity = Vector2.ZERO
		if _body.sprite.sprite_frames.has_animation("die"):
			_body.sprite.play("die")
		
		timer.start()

func _on_timer_timeout():
	
	get_tree().reload_current_scene()
