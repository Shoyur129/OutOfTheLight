extends CharacterBody2D


const SPEED: float = 150.0
const JUMP_VELOCITY: float = -370.0

@export var health: int = 5
@onready var attack_area: Area2D = $AttackArea
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

signal health_changed(new_health: int)

var is_attacking: bool = false
var attack_damage: int = 1
var is_dead: bool = false
var is_hurt: bool = false
var hurt_timer: float = 0.0
var hurt_duration: float = 0.6  # Duration of hurt state in seconds


func _ready():
	add_to_group("player")
	sprite.play("Idle")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Decrement hurt timer
	if is_hurt:
		hurt_timer -= delta
		if hurt_timer <= 0:
			is_hurt = false
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("Attacking") and not is_attacking and not is_hurt:
		attack()
	var direction := Input.get_axis("move_left", "move_right")
	if not is_attacking:
		if direction:
			velocity.x = direction * SPEED
			if direction < 0:
				sprite.flip_h = true
				attack_area.position.x = -abs(attack_area.position.x)
			elif direction > 0:
				sprite.flip_h = false
				attack_area.position.x = abs(attack_area.position.x)
			if is_on_floor() and not is_hurt:
				if sprite.animation != "run":
					sprite.play("run")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if is_on_floor() and not is_hurt:
				if sprite.animation != "Idle":
					sprite.play("Idle")

	if not is_on_floor() and not is_hurt and not is_attacking:
		if sprite.animation != "jump":
			sprite.play("jump")
	move_and_slide()

func attack() -> void:
	is_attacking = true
	velocity.x = 0
	if sprite.sprite_frames.has_animation("Slashing"):
		sprite.play("Slashing")
	elif sprite.sprite_frames.has_animation("Attacking"):
		sprite.play("Attacking")
	for body in attack_area.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)

func take_damage(amount: int = 1) -> void:
	if is_dead:
		return
	health -= amount
	print("Player health: ", health)
	health_changed.emit(health)
	if health <= 0:
		die()
		return
	else:
		hurt()
		return

func get_damage(damage: int = 1) -> void:
	take_damage(damage)

func hurt() -> void:
	is_hurt = true
	hurt_timer = hurt_duration
	if sprite.sprite_frames.has_animation("Hurt"):
		sprite.play("Hurt")
		return

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO

	if sprite.sprite_frames.has_animation("die"):
		sprite.play("die")
		return
		
	else:
		queue_free()
		return
func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "Slashing" or sprite.animation == "Attacking":
		is_attacking = false
	elif sprite.animation == "Hurt":
		is_hurt = false
	elif sprite.animation == "die":
		get_tree().reload_current_scene()
		queue_free()
