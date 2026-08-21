class_name WaveManager
extends Node

var player: Player
var arena := Vector2(1152, 648)

var wave := 0
var wave_time := 0.0
var shopping := false
var finished := false

const WAVE_LENGTH := [0.0, 22.0, 26.0, 30.0, 34.0, 70.0]
const BOSS_WAVE := 5

var _spawn_cd := 0.0
var _boss_spawned := false


func _ready() -> void:
	start_wave(1)


func start_wave(n: int) -> void:
	wave = n
	wave_time = WAVE_LENGTH[mini(n, WAVE_LENGTH.size() - 1)]
	shopping = false
	_spawn_cd = 0.5
	_boss_spawned = false


func _process(delta: float) -> void:
	if finished or player == null or not player.alive:
		return
	if shopping:
		_shop_input()
		return

	if wave == BOSS_WAVE and not _boss_spawned:
		_boss_spawned = true
		_make(Enemy.Kind.CIGAR, Vector2(arena.x * 0.5, 90.0))

	if wave == BOSS_WAVE and _boss_spawned and not _boss_alive():
		_end_wave()
		return

	wave_time -= delta
	_spawn_cd -= delta
	if _spawn_cd <= 0.0:
		_spawn_cd = maxf(0.45, 1.7 - wave * 0.2)
		_spawn()
	if wave_time <= 0.0:
		_end_wave()


func _spawn() -> void:
	var roll := randf()
	# Bongs are the only pressure now, so they spawn INSIDE the arena.
	# The floor slowly fills with people you cannot see. That is the squeeze.
	if wave >= 2 and roll > 0.66:
		_make(Enemy.Kind.BONG, _interior_point())
		return
	if wave >= 3 and roll > 0.44:
		_make(Enemy.Kind.CHASER, _edge_point())
		return
	_make(Enemy.Kind.VAPER, _edge_point())


func _boss_alive() -> bool:
	for n in get_tree().get_nodes_in_group("enemies"):
		if (n as Enemy).kind == Enemy.Kind.CIGAR:
			return true
	return false


func _make(k: int, at: Vector2) -> void:
	var e := Enemy.new()
	e.setup(k)
	e.player = player
	e.position = at
	get_parent().add_child(e)


func _edge_point() -> Vector2:
	match randi() % 4:
		0:
			return Vector2(randf() * arena.x, -20.0)
		1:
			return Vector2(randf() * arena.x, arena.y + 20.0)
		2:
			return Vector2(-20.0, randf() * arena.y)
		_:
			return Vector2(arena.x + 20.0, randf() * arena.y)


# Never drop a junkie right on top of the player - that is unfair, not tense.
func _interior_point() -> Vector2:
	for i in range(20):
		var p := Vector2(randf_range(90.0, arena.x - 90.0), randf_range(90.0, arena.y - 90.0))
		if p.distance_to(player.position) > 220.0:
			return p
	return Vector2(arena.x - 90.0, arena.y - 90.0)


func _end_wave() -> void:
	for n in get_tree().get_nodes_in_group("enemies"):
		n.queue_free()
	for n in get_tree().get_nodes_in_group("clouds"):
		n.queue_free()
	if wave >= BOSS_WAVE:
		finished = true
		return
	shopping = true


# The entire shop. KILL vs CLEAR vs LUNGS. That is the build tension.
func _shop_input() -> void:
	if Input.is_key_pressed(KEY_1):
		player.bullet_damage += 4.0
		_next()
	elif Input.is_key_pressed(KEY_2):
		player.upgrade_fan()
		_next()
	elif Input.is_key_pressed(KEY_3):
		player.max_breath += 15.0
		_next()


func _next() -> void:
	player.breath = player.max_breath
	start_wave(wave + 1)
