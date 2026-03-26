extends CharacterBody2D

const SPEED = 90.0
const JUMP_VELOCITY = -180.0
const GRAVITY = 500.0
const FRICTION = 350.0  # الاحتكاك العادي
const ZERO_ENERGY_FRICTION = 100.0  # احتكاك أبطأ عند نفاد الطاقة
@export var max_energy: float = 300.0
@export var start_energy: float = 300.0
@export var energy_drain_rate: float = 50.0
@export var capacity_multiplier: float = 1.0
var energy: float = 0.0 # الطاقة الحالية
var infinite_battery := false
signal energy_changed(value)
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	max_energy = max_energy * capacity_multiplier
	start_energy = min(start_energy * capacity_multiplier, max_energy)
	energy = start_energy
	emit_signal("energy_changed", energy)
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

	var direction := Input.get_axis("left", "right")
	if can_use_energy and direction != 0:
		velocity.x = direction * SPEED
		sprite_2d.flip_h = direction < 0
	else:
		# استخدم ZERO_ENERGY_FRICTION عند نفاد الطاقة، وإلا استخدم FRICTION العادي
		var friction = FRICTION
		if not infinite_battery and energy == 0:
			friction = ZERO_ENERGY_FRICTION
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()

	# خصم الطاقة فقط إذا كان هناك إدخال حركة وحصلت حركة أفقية فعلية
	var moved_x: float = absf(global_position.x - prev_x)
	if not infinite_battery and energy > 0 and direction != 0 and moved_x > 0.001:
		var old_energy = energy
		energy = max(energy - energy_drain_rate * delta, 0)
		if energy != old_energy:
			emit_signal("energy_changed", energy)

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
