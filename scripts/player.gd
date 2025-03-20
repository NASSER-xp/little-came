extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -180.0
const GRAVITY = 500.0
const FRICTION = 500.0  # قيمة الاحتكاك للتباطؤ التدريجي
@onready var sprite_2d: Sprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
		# Flip the sprite based on direction
		sprite_2d.flip_h = direction < 0  # Flip if moving left
	else:
		# Reduce velocity gradually when no input is given
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Move the player
	move_and_slide()


func _on_coin_collectable_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
