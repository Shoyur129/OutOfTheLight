extends CharacterBody2D

@export var move_speed: float = 45.0
@export var patrol_distance: float = 120.0
@export var health: int = 5
@export var chase_speed: float = 55.0
@export var chase_range: float = 140.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var shoot_timer: Timer = $ShootTimer
@onready var turn_timer: Timer = $TurnTimer
@onready var shoot_point: Marker2D = $ShootPoint

var start_position: Vector2
var moving_right: bool = true
var player_in_range: bool = false
var is_dead: bool = false
var is_hurt: bool = false
var is_waiting_to_turn: bool = false
var player_ref: Node2D = null

func _ready() -> void:
	start_position = global_position
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if is_hurt:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if player_in_range and player_ref != null:
		handle_player_behavior()
	else:
		patrol()
		move_and_slide()

func patrol() -> void:
	if is_waiting_to_turn:
		velocity.x = 0
		play_animation_if_not_playing("idle")
		return
	if moving_right:
		velocity.x = move_speed
		sprite.flip_h = false
	if global_position.x >= start_position.x + patrol_distance:
		velocity.x = 0
		is_waiting_to_turn = true
		turn_timer.start()
	else:
		velocity.x = -move_speed
		sprite.flip_h = true
	if global_position.x <= start_position.x - patrol_distance:
		velocity.x = 0
		is_waiting_to_turn = true
		turn_timer.start()
	play_animation_if_not_playing("Walking")

func handle_player_behavior() -> void:
	var distance_to_player = global_position.distance_to(player_ref.global_position)
	if distance_to_player > chase_range:
		velocity.x = 0
		play_animation_if_not_playing("Shooting")
		return
	if player_ref.global_position.x > global_position.x:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	if abs(player_ref.global_position.x - global_position.x) > 60:
		if player_ref.global_position.x > global_position.x:
			velocity.x = chase_speed
		else:
			velocity.x = -chase_speed
			play_animation_if_not_playing("Walking")
	else:
			velocity.x = 0
			play_animation_if_not_playing("Shooting")

func take_damage(amount: int) -> void:
	if is_dead:
		return
	health -= amount
	if health <= 0:
		die()
	else:
		play_hurt()

func play_hurt() -> void:
	is_hurt = true
	velocity = Vector2.ZERO
	sprite.play("Hurt")

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	shoot_timer.stop()
	turn_timer.stop()
	sprite.play("Dying")

func play_animation_if_not_playing(anim_name: String) -> void:
	if sprite.animation != anim_name:
		sprite.play(anim_name)

func _on_detection_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body as Node2D
		shoot_timer.start()

func _on_detection_area_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		player_ref = null
		shoot_timer.stop()

func _on_shoot_timer_timeout() -> void:
	if is_dead:
		return
	if player_in_range and player_ref != null:
		print("Archer 2 shoots from ShootPoint")

func _on_turn_timer_timeout() -> void:
	moving_right = not moving_right
	is_waiting_to_turn = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "Hurt" and not is_dead:
		is_hurt = false
		if player_in_range and player_ref != null:
			handle_player_behavior()
		else:
			sprite.play("idle")
	elif sprite.animation == "Dying":
		queue_free()
