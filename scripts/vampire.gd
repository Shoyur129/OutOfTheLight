extends CharacterBody2D

@export var health: int = 3
@export var chase_speed: float = 55.0
@export var chase_range: float = 140.0

@onready var sprite = $AnimatedSprite2D
@onready var detection = $DetectionArea
@onready var attack_timer = $AttackTimer
@onready var ray_left = $RayLeft
@onready var ray_right = $RayRight


var speed = 70
var direction = -1
var player = null
var player_in_range = false
var can_attack = true
var is_attacking = false
var is_dead = false
var is_hurt = false
var start_position: Vector2
var moving_right: bool = true
var move_speed: float = 30.0
var patrol_distance: float = 80.0

func _ready():
	start_position = global_position
	attack_timer.wait_time = 1.5
	attack_timer.one_shot = true

func _physics_process(delta):
	if is_dead:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Check for player in detection area using physics
	player_in_range = false
	player = null
	for body in detection.get_overlapping_bodies():
		if body.name == "Player" or body.is_in_group("player"):
			player_in_range = true
			player = body
			break
	
	if player_in_range and player != null:
		var move_direction = (player.global_position - global_position).normalized()
		if not is_attacking and not is_hurt:
			velocity.x = move_direction.x * speed
			move_and_slide()
			if move_direction.x < 0:
				sprite.flip_h = true
				sprite.play("Running")
			elif move_direction.x > 0:
				sprite.flip_h = false
				sprite.play("Running")
		if global_position.distance_to(player.global_position) < 80 and can_attack:
				attack()
	else:
		if not is_attacking and not is_hurt:
			patrol()
		else:
			velocity.x = 0
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

func attack():
	can_attack = false
	is_attacking = true
	velocity.x = 0
	sprite.play("Slashing")
	if player != null and global_position.distance_to(player.global_position) < 90:
		if player.has_method("take_damage"):
			player.take_damage(1)
		elif player.has_method("get_damage"):
				player.get_damage(1)
	attack_timer.start()

func _on_attack_timer_timeout():
	can_attack = true

func take_damage(amount: int = 1):
	if is_dead:
		return
	health -= amount
	if health <= 0:
		die()
		return
	is_hurt = true
	sprite.play("Hurt")

func die():
	is_dead = true
	velocity.x = 0
	if player and player.has_method("heal"):
		player.heal(1)
	GameState.add_score()
	player = null
	sprite.play("Dying")

func play_animation_if_not_playing(anim_name: String) -> void:
	if is_dead:
		return
	if sprite.animation != anim_name:
		sprite.play(anim_name)

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "Slashing":
		is_attacking = false
	elif sprite.animation == "Hurt":
		is_hurt = false
	elif sprite.animation == "Dying":
		queue_free()
