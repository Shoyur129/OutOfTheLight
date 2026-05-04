extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var detection = $DetectionArea
@onready var attack_timer = $AttackTimer

var speed = 80
var player = null
var player_in_range = false
var is_attacking = false
var is_dead = false
var is_hurt = false

func _ready():
	attack_timer.wait_time = 1.5
	attack_timer.start()

func _physics_process(delta):
	if is_dead:
		return
	if player_in_range and player != null:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
	if not is_attacking and not is_hurt:
		sprite.play("Walking")
	else:
		velocity = Vector2.ZERO
	if not is_attacking and not is_hurt:
		sprite.play("Idle")

func _on_detection_area_body_entered(body):
	if body.name == "Player":
		player = body
		player_in_range = true
		
func _on_detection_area_body_exited(body):
	if body.name == "Player":
		player = null
		player_in_range = false

func _on_attack_timer_timeout():
	if is_dead:
		return
	if player_in_range and not is_attacking:
		attack()

func attack():
	is_attacking = true
	velocity = Vector2.ZERO
	sprite.play("Slashing")

func take_damage():
	if is_dead:
		return
	is_hurt = true
	sprite.play("Hurt")

func die():
	is_dead = true
	velocity = Vector2.ZERO
	sprite.play("Dying")

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "Slashing":
		is_attacking = false
	elif sprite.animation == "Hurt":
		is_hurt = false
	elif sprite.animation == "Dying":
		queue_free()
