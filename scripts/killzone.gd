extends Area2D

@onready var timer = $Timer

var checkpoint_manager
var player

func _ready() -> void:
	checkpoint_manager = get_parent().get_node("checkpointManager")
	player = get_parent().get_node("Player")

func _on_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("player"):
		_body.is_dead = true
		_body.velocity = Vector2.ZERO
		if _body.sprite.sprite_frames.has_animation("die"):
			_body.sprite.play("die")
		
		timer.start()

func _on_timer_timeout():
	if checkpoint_manager and checkpoint_manager.last_location != null:
		# Respawn at checkpoint
		player.global_position = checkpoint_manager.last_location
		player.is_dead = false
		player.is_hurt = false
		player.is_attacking = false
		player.velocity = Vector2.ZERO
		player.health = 5
		player.health_changed.emit(player.health)
		if player.sprite.sprite_frames.has_animation("Idle"):
			player.sprite.play("Idle")
	else:
		# No checkpoint set, reload scene
		get_tree().reload_current_scene()
