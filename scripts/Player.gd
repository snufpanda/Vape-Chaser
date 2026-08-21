class_name Player
extends Node2D

const RADIUS := 14.0
const MAX_SPEED := 260.0

# The CLEAR upgrade path. You start pathetic on purpose.
const FAN_TIERS: Array[String] = ["HAND FAN", "DESK FAN", "BOX FAN", "LEAF BLOWER", "EXTRACTOR"]

var arena := Vector2(1152, 648)

# --- BREATH is your HP. Only thick smoke and bodies take it. ---
var max_breath := 100.0
var breath := 100.0
var breath_regen := 9.0

# --- KILL family: hits people ---
var fire_rate := 0.30
var fire_range := 340.0
var bullet_damage := 12.0

# --- CLEAR family: moves air. Kills nothing. Starts as a little hand fan. ---
var fan_tier := 0
var fan_radius := 58.0
var fan_power := 14.0

var coins := 0
var alive := true

var _fire_cd := 0.0
var _aim := Vector2.RIGHT


func _ready() -> void:
	z_index = 20
	add_to_group("player")


func _process(delta: float) -> void:
	if not alive:
		return
	_move(delta)
	_fan(delta)
	_breathe(delta)
	_fire(delta)
	queue_redraw()


func _move(delta: float) -> void:
	var d := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		d.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		d.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		d.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		d.y += 1.0
	if d != Vector2.ZERO:
		d = d.normalized()
		_aim = d
		position += d * MAX_SPEED * delta
	position.x = clampf(position.x, RADIUS, arena.x - RADIUS)
	position.y = clampf(position.y, RADIUS, arena.y - RADIUS)


# The CLEAR weapon. Eats clouds, kills nothing.
# It is also the only thing that can knock the Don's cigar out --
# which stops his fog and starts his gunfire. Your call.
func _fan(delta: float) -> void:
	for n in get_tree().get_nodes_in_group("clouds"):
		var c := n as Cloud
		if position.distance_to(c.position) < fan_radius + c.radius:
			c.radius -= fan_power * delta
	for n in get_tree().get_nodes_in_group("enemies"):
		var e := n as Enemy
		if e.kind == Enemy.Kind.CIGAR and position.distance_to(e.position) < fan_radius + e.radius:
			e.knock_cigar()


func upgrade_fan() -> void:
	fan_power += 10.0
	fan_radius += 14.0
	fan_tier = mini(fan_tier + 1, FAN_TIERS.size() - 1)


func fan_name() -> String:
	return FAN_TIERS[fan_tier]


func _breathe(delta: float) -> void:
	var choke := 0.0
	for n in get_tree().get_nodes_in_group("clouds"):
		var c := n as Cloud
		if c.density > 0.0 and position.distance_to(c.position) < c.radius:
			choke += c.density
	if choke > 0.0:
		breath -= choke * 10.0 * delta
	else:
		breath = minf(max_breath, breath + breath_regen * delta)
	if breath <= 0.0:
		breath = 0.0
		alive = false


# The KILL weapon. Auto-targets nearest. You never aim.
func _fire(delta: float) -> void:
	_fire_cd -= delta
	if _fire_cd > 0.0:
		return
	var target: Node2D = null
	var best := fire_range
	for n in get_tree().get_nodes_in_group("enemies"):
		var e := n as Node2D
		var dist := position.distance_to(e.position)
		if dist < best:
			best = dist
			target = e
	if target == null:
		return
	_fire_cd = fire_rate
	var b := Bullet.new()
	b.position = position
	b.dir = (target.position - position).normalized()
	b.damage = bullet_damage
	get_parent().add_child(b)


func hurt(amount: float) -> void:
	breath -= amount
	if breath <= 0.0:
		breath = 0.0
		alive = false


func _draw() -> void:
	draw_circle(Vector2.ZERO, fan_radius, Color(0.50, 0.89, 0.83, 0.05))
	draw_arc(Vector2.ZERO, fan_radius, 0.0, TAU, 48, Color(0.50, 0.89, 0.83, 0.18), 1.0)
	draw_circle(Vector2.ZERO, RADIUS, Color("e9f6f3"))
	draw_circle(_aim * 9.0, 5.0, Color("7fe3d4"))
