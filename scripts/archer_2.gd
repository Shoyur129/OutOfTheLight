extends CharacterBody2D
@export var arrow_scene: PackedScene
@export var move_speed: float = 30.0
@export var patrol_distance: float = 80.0
@export var health: int = 2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_point: Marker2D = $ShootPoint
@onready var ray_left: RayCast2D = $RayLeft
@onready var ray_right: RayCast2D = $RayRight

var start_position: Vector2
var moving_right: bool = true
var player_in_range: bool = false
var player_ref: Node2D = null
var is_dead: bool = false
var is_hurt: bool = false

func _ready() -> void:
	start_position = global_position
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_dead:
		velocity.x = 0
		move_and_slide()
		return
	if is_hurt:
		velocity.x = 0
		move_and_slide()
		return
	if player_in_range and player_ref != null:
		attack_player()
	else:
		patrol()
	move_and_slide()

func patrol() -> void:
	if ray_left.is_colliding():
		moving_right = true
	if ray_right.is_colliding():
		moving_right = false
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
	play_animation_if_not_playing("Running")

func attack_player() -> void:
	velocity.x = 0
	if player_ref.global_position.x < global_position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	play_animation_if_not_playing("Shooting")

func take_damage(amount: int = 1) -> void:
	if is_dead:
		return
	health -= amount
	print("Archer 1 health: ", health)
	if health <= 0:
		die()
	else:
		play_hurt()

func play_hurt() -> void:
	is_hurt = true
	velocity.x = 0
	if sprite.sprite_frames.has_animation("Hurt"):
		sprite.play("Hurt")
	else:
		is_hurt = false

func die() -> void:
	is_dead = true
	is_hurt = false
	player_in_range = false
	player_ref = null
	velocity.x = 0
	shoot_timer.stop()
	if sprite.sprite_frames.has_animation("Dying"):
		sprite.play("Dying")
	else:
		queue_free()

func shoot_arrow() -> void:
	if is_dead:
		return
	if arrow_scene == null:
		return
	if player_ref == null:
		return
	var arrow = arrow_scene.instantiate()
	get_parent().add_child(arrow)
	arrow.global_position = shoot_point.global_position
	var shoot_direction = (player_ref.global_position - shoot_point.global_position).normalized()
	if arrow.has_method("set_direction"):
		arrow.set_direction(shoot_direction)

func play_animation_if_not_playing(anim_name: String) -> void:
	if is_dead:
		return
	if sprite.animation != anim_name:
		sprite.play(anim_name)

func _on_detection_area_body_entered(body: Node) -> void:
	if is_dead:
		return
	if body.name == "Player" or body.is_in_group("player"):
		player_in_range = true
		player_ref = body
		shoot_timer.start()

func _on_detection_area_body_exited(body: Node) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		player_in_range = false
		player_ref = null
		shoot_timer.stop()

func _on_shoot_timer_timeout() -> void:
	if is_dead:
		return
	if player_in_range and player_ref != null:
		shoot_arrow()
		print("Archer 1 shoots arrow")

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "Dying":
		queue_free()
		return
	if is_dead:
		return

	if sprite.animation == "Hurt":
		is_hurt = false
