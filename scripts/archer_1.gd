extends CharacterBody2D

@export var arrow_scene: PackedScene
@export var move_speed: float = 30.0
@export var patrol_distance: float = 80.0
@export var health: int = 3

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_point: Marker2D = $ShootPoint

var start_position: Vector2
var moving_right: bool = true
var player_in_range: bool = false
var is_dead: bool = false
var is_hurt: bool = false
var player_ref: Node2D = null

func _ready() -> void:
	start_position = global_position
	sprite.play("idle")

func _physics_process(delta: float):
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if is_hurt:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if player_in_range:
		attack_player()
	else:
			patrol()
			move_and_slide()

func patrol():
	if moving_right:
		velocity.x = move_speed
		sprite.flip_h = false
	if global_position.x >= start_position.x + patrol_distance:
		moving_right = false
	else:
			velocity.x = -move_speed
			sprite.flip_h = true
	if global_position.x <= start_position.x - patrol_distance:
		moving_right = true
		play_animation_if_not_playing("Walking")

func attack_player():
	velocity.x = 0
	play_animation_if_not_playing("Shooting")

func take_damage(amount: int):
	if is_dead:
		return
		health -= amount
	if health <= 0:
		die()
	else:
		play_hurt()

func play_hurt():
	is_hurt = true
	velocity = Vector2.ZERO
	sprite.play("Hurt")

func die():
	is_dead = true
	velocity = Vector2.ZERO
	sprite.play("Dying")

func play_animation_if_not_playing(anim_name: String):
	if sprite.animation != anim_name:
		sprite.play(anim_name)

func _on_detection_area_body_entered(body: Node):
	if body.name == "Player" or body.is_in_group("player"):
		player_in_range = true
		player_ref = body
		shoot_timer.start()

func _on_detection_area_body_exited(body: Node):
	if body.name == "Player" or body.is_in_group("player"):
		player_in_range = false
		player_ref = null
		shoot_timer.stop()

func _on_shoot_timer_timeout():
	if is_dead:
		return
	if player_in_range and player_ref != null and arrow_scene != null:
		var arrow = arrow_scene.instantiate()
		get_parent().add_child(arrow)
		arrow.global_position = shoot_point.global_position
		var shoot_direction = (player_ref.global_position - shoot_point.global_position).normalized()
		if arrow.has_method("set_direction"):
			arrow.set_direction(shoot_direction)
		sprite.play("Shooting")
	if player_in_range:
		print("Archer attacks from ShootPoint")

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "Hurt" and not is_dead:
		is_hurt = false
		if player_in_range:
			sprite.play("Shooting")
		else:
			sprite.play("idle")
	elif sprite.animation == "Dying":
		queue_free()
