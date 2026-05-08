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

func _ready():
	attack_timer.wait_time = 1.5
	attack_timer.one_shot = true

func _physics_process(delta):
	if is_dead:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
	if player_in_range and player != null:
		var move_direction = (player.global_position - global_position).normalized()
		if not is_attacking and not is_hurt:
			velocity.x = move_direction.x * speed
			move_and_slide()
			if move_direction.x < 0:
				sprite.flip_h = true
			elif move_direction.x > 0:
				sprite.flip_h = false
				sprite.play("Running")
		if global_position.distance_to(player.global_position) < 80 and can_attack:
				attack()
	else:
		velocity.x = 0
		move_and_slide()
		if not is_attacking and not is_hurt:
			sprite.play("Idle")
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

func _on_detection_area_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		player = body
		player_in_range = true

func _on_detection_area_body_exited(body):
	if body.name == "Player" or body.is_in_group("player"):
		player = null
		player_in_range = false

func take_damage(amount: int = 1):
	if is_dead:
		return
	health -= amount
	if health <= 0:
		die()
	is_hurt = true
	sprite.play("Hurt")

func die():
	is_dead = true
	velocity.x = 0
	sprite.play("Dying")

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "Slashing":
		is_attacking = false
	elif sprite.animation == "Hurt":
		is_hurt = false
	elif sprite.animation == "Dying":
		queue_free()
