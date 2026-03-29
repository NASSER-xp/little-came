extends CharacterBody2D

const SPEED = 90.0
const JUMP_VELOCITY = -180.0
const GRAVITY = 500.0
const FRICTION = 350.0  # الاحتكاك العادي
const ZERO_ENERGY_FRICTION = 100.0  # احتكاك أبطأ عند نفاد الطاقة
const DASH_SPEED = 200.0
const DASH_DURATION = 0.3
const DASH_STAMINA_COST = 70
const DASH_STAMINA_REGEN = 5.0
const ACCELERATION = 600.0  # تسارع الحركة الأفقية

@export var max_energy: float = 300.0
@export var start_energy: float = 300.0
@export var energy_drain_rate: float = 50.0
@export var capacity_multiplier: float = 1.0
var energy: float = 0.0 # الطاقة الحالية
var infinite_battery := false
var is_dashing := false
var can_dash := true
var dash_stamina: float = 100.0
var max_dash_stamina: float = 100.0

signal energy_changed(value)
signal dash_stamina_changed(value)
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	max_energy = max_energy * capacity_multiplier
	start_energy = min(start_energy * capacity_multiplier, max_energy)
	energy = start_energy
	
	infinite_battery = GlobalState.infinite_battery
	if infinite_battery:
		energy = max_energy
		
	emit_signal("energy_changed", energy)
	emit_signal("dash_stamina_changed", dash_stamina)
	_connect_void_kill_zone()

func _physics_process(delta: float) -> void:
	var prev_x := global_position.x
	var can_use_energy := infinite_battery or energy > 0

	# الجاذبية
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# القفز
	if Input.is_action_just_pressed("jump") and is_on_floor() and can_use_energy:
		velocity.y = JUMP_VELOCITY

	# اندفاع (Dash)
	if Input.is_action_just_pressed("dash") and can_dash and dash_stamina >= DASH_STAMINA_COST and can_use_energy:
		start_dash()

	var direction := Input.get_axis("left", "right")
	
	if is_dashing:
		# أثناء الاندفاع، نتحرك بسرعة ثابتة في الاتجاه الحالي
		velocity.x = (1 if not sprite_2d.flip_h else -1) * DASH_SPEED
		velocity.y = 0
	elif can_use_energy and direction != 0:
		# Use move_toward with ACCELERATION to allow external forces to linger
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		sprite_2d.flip_h = direction < 0
	else:
		# استخدم ZERO_ENERGY_FRICTION عند نفاد الطاقة، وإلا استخدم FRICTION العادي
		var friction = FRICTION
		if not infinite_battery and energy == 0:
			friction = ZERO_ENERGY_FRICTION
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()
	
	# تجديد الستامينا
	if not is_dashing and dash_stamina < max_dash_stamina:
		dash_stamina = min(dash_stamina + DASH_STAMINA_REGEN * delta, max_dash_stamina)
		emit_signal("dash_stamina_changed", dash_stamina)

	# خصم الطاقة فقط إذا كان هناك إدخال حركة وحصلت حركة أفقية فعلية
	var moved_x: float = absf(global_position.x - prev_x)
	if not infinite_battery and energy > 0 and direction != 0 and moved_x > 0.001:
		var old_energy = energy
		energy = max(energy - energy_drain_rate * delta, 0)
		if energy != old_energy:
			emit_signal("energy_changed", energy)

func start_dash() -> void:
	is_dashing = true
	can_dash = false
	dash_stamina -= DASH_STAMINA_COST
	emit_signal("dash_stamina_changed", dash_stamina)
	
	# استهلاك الطاقة للاندفاع بدلاً من المشي العادي (اختياري)
	add_energy(-10.0) 
	
	await get_tree().create_timer(DASH_DURATION).timeout
	is_dashing = false
	
	# منع الاندفاع مرة أخرى فوراً إذا لزم الأمر (cooldown)
	await get_tree().create_timer(0.1).timeout 
	can_dash = true

# دالة لزيادة طاقة اللاعب بشكل آمن
func add_energy(amount: float) -> void:
	var old_energy = energy
	energy = min(energy + amount, max_energy)
	if energy != old_energy:
		emit_signal("energy_changed", energy)

func increase_max_energy(amount: float) -> void:
	if amount <= 0.0:
		return
	max_energy += amount
	energy = min(energy, max_energy)
	emit_signal("energy_changed", energy)


func set_infinite_battery(enabled: bool) -> void:
	infinite_battery = enabled
	if infinite_battery:
		var old_energy = energy
		energy = max_energy
		if energy != old_energy:
			emit_signal("energy_changed", energy)


func _on_coin_collectable_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.

func _connect_void_kill_zone() -> void:
	var void_area := get_tree().current_scene.find_child("Void", true, false)
	if void_area is Area2D and not void_area.body_entered.is_connected(_on_void_body_entered):
		void_area.body_entered.connect(_on_void_body_entered)

func _on_void_body_entered(body: Node2D) -> void:
	if body == self:
		get_tree().reload_current_scene()
