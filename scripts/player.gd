extends CharacterBody2D


const SPEED: float = 150.0
const JUMP_VELOCITY: float = -375.0

@export var health: int = 5
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_dead: bool = false
var is_hurt: bool = false

func _ready():
	add_to_group("player")
	sprite.play("Idle")

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float):
	if is_dead:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direstion
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
		if direction < 0:
			sprite.flip_h = true
		elif direction > 0:
			sprite.flip_h = false
		if is_on_floor() and not is_hurt:
			sprite.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() and not is_hurt:
			sprite.play("Idle")
	if not is_on_floor() and not is_hurt:
		sprite.play("Jump")
	move_and_slide()

func take_damage(amount: int = 1):
	if is_dead:
		return
	health -= amount
	print("Player health: ", health)
	if health <= 0:
		die()
	else:
		hurt()

func get_damage(damage: int = 1):
	take_damage(damage)

func hurt() -> void:
	is_hurt = true
	if sprite.sprite_frames.has_animation("Hurt"):
		sprite.play("Hurt")

func die():
	is_dead = true
	velocity = Vector2.ZERO
	if sprite.sprite_frames.has_animation("Dying"):
		sprite.play("Dying")
	else:
		queue_free()

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "Hurt":
		is_hurt = false
	elif sprite.animation == "Dying":
		queue_free()
