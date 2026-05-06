extends Area2D

@export var speed: float = 250.0
@export var damage: int = 1

var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta: float):
	global_position += direction * speed * delta

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()
	if direction.x < 0:
		scale.x = -abs(scale.x)
	else:
		scale.x = abs(scale.x)

func _on_body_entered(body: Node):
	if body.name == "Player" or body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			queue_free()
	else:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
