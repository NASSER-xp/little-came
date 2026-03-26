extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -180.0
const GRAVITY = 500.0
const FRICTION = 350.0  # الاحتكاك العادي
const ZERO_ENERGY_FRICTION = 100.0  # احتكاك أبطأ عند نفاد الطاقة
var energy := 300 # الطاقة القصوى
signal energy_changed(value)
@onready var sprite_2d: Sprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
	var prev_x := global_position.x

	# الجاذبية
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# القفز
	if Input.is_action_just_pressed("jump") and is_on_floor() and energy > 0:
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("left", "right")
	if energy > 0 and direction != 0:
		velocity.x = direction * SPEED
		sprite_2d.flip_h = direction < 0
	else:
		# استخدم ZERO_ENERGY_FRICTION عند نفاد الطاقة، وإلا استخدم FRICTION العادي
		var friction = FRICTION
		if energy == 0:
			friction = ZERO_ENERGY_FRICTION
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()

	# خصم الطاقة فقط إذا كان هناك إدخال حركة وحصلت حركة أفقية فعلية
	var moved_x: float = absf(global_position.x - prev_x)
	if energy > 0 and direction != 0 and moved_x > 0.001:
		var old_energy = energy
		energy = max(energy - 1 * delta, 0)
		if energy != old_energy:
			emit_signal("energy_changed", energy)

# دالة لزيادة طاقة اللاعب بشكل آمن
func add_energy(amount: float) -> void:
	var old_energy = energy
	energy = min(energy + amount, 300)
	if energy != old_energy:
		emit_signal("energy_changed", energy)


func _on_coin_collectable_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.
