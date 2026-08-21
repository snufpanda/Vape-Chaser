class_name Enemy
extends Node2D

# ONE JOB EACH. That is the whole roster rule.
#   VAPER  - blinds you. cannot hurt you at all.
#   CHASER - blinds you bigger. cannot hurt you at all.
#   BONG   - a junkie sitting on the floor. never moves. crash into him and he smashes you.
#   CIGAR  - the boss. lit = he fogs the room. blow it off with the fan = he shoots.
enum Kind { VAPER, CHASER, BONG, CIGAR }

var kind := Kind.VAPER
var player: Player

var hp := 16.0
var speed := 62.0
var standoff := 200.0
var radius := 12.0
var value := 2
var color := Color("c25e57")

# contact damage (BONG only)
var contact_radius := 0.0
var contact_damage := 0.0
var contact_every := 0.9

# smoke
var puff_every := 1.4
var puff_radius := 100.0
var puff_density := 0.0
var puff_opacity := 0.55
var puff_drift := 14.0
var puff_decay := 3.0

# CIGAR boss state
var lit := true
var relight_every := 6.0
var shot_every := 0.75
var shot_damage := 9.0

var _contact_cd := 0.0
var _puff_cd := 0.8
var _shot_cd := 0.0
var _relight_cd := 0.0


func setup(k: int) -> void:
	kind = k
	match k:
		Kind.VAPER:
			# Zero threat. Pure vision denial. He is a support unit.
			hp = 16.0
			speed = 62.0
			standoff = 200.0
			radius = 12.0
			value = 2
			color = Color("c25e57")
			puff_every = 1.4
			puff_radius = 100.0
			puff_density = 0.0
			puff_opacity = 0.55
			puff_decay = 3.0
		Kind.CHASER:
			# Cloud-chaser. Same zero threat, much bigger fog.
			hp = 34.0
			speed = 40.0
			standoff = 280.0
			radius = 14.0
			value = 4
			color = Color("9a6f52")
			puff_every = 2.0
			puff_radius = 180.0
			puff_density = 0.0
			puff_opacity = 0.40
			puff_decay = 4.0
		Kind.BONG:
			# Sits. Never moves. Never chases. You walk into him.
			hp = 70.0
			speed = 0.0
			standoff = 0.0
			radius = 18.0
			value = 6
			color = Color("7d2f2a")
			contact_radius = 36.0
			contact_damage = 22.0
			contact_every = 0.9
			puff_every = 2.2
			puff_radius = 62.0
			puff_density = 1.4
			puff_opacity = 0.50
			puff_drift = 4.0
			puff_decay = 2.5
		Kind.CIGAR:
			# THE DON.
			hp = 320.0
			speed = 30.0
			standoff = 240.0
			radius = 26.0
			value = 40
			color = Color("4a2b22")
			puff_every = 1.3
			puff_radius = 210.0
			puff_density = 0.9
			puff_opacity = 0.80
			puff_drift = 8.0
			puff_decay = 5.0


func _ready() -> void:
	z_index = 5
	add_to_group("enemies")


func _process(delta: float) -> void:
	if player == null or not player.alive:
		return
	var to_player := player.position - position
	var dist := to_player.length()

	if speed > 0.0 and dist > standoff:
		position += to_player.normalized() * speed * delta

	if contact_damage > 0.0:
		_contact_cd -= delta
		if dist <= contact_radius and _contact_cd <= 0.0:
			_contact_cd = contact_every
			player.hurt(contact_damage)

	if kind == Kind.CIGAR:
		_boss(delta, to_player, dist)
	else:
		_smoke(delta)

	queue_redraw()


# Lit  -> he fogs the whole room and never shoots.
# Knocked out -> the fog stops and he shoots at you.
# You choose which one you would rather deal with. That is the fight.
func _boss(delta: float, to_player: Vector2, dist: float) -> void:
	if lit:
		_smoke(delta)
		return
	_relight_cd -= delta
	if _relight_cd <= 0.0:
		lit = true
		return
	_shot_cd -= delta
	if _shot_cd <= 0.0 and dist < 620.0:
		_shot_cd = shot_every
		var b := Bullet.new()
		b.hostile = true
		b.position = position
		b.dir = to_player.normalized()
		b.speed = 300.0
		b.damage = shot_damage
		get_parent().add_child(b)


# Called by the player's fan when it reaches him.
func knock_cigar() -> void:
	if kind != Kind.CIGAR or not lit:
		return
	lit = false
	_relight_cd = relight_every
	_shot_cd = 0.5


func _smoke(delta: float) -> void:
	_puff_cd -= delta
	if _puff_cd > 0.0:
		return
	_puff_cd = puff_every
	var c := Cloud.new()
	c.position = position
	c.radius = puff_radius
	c.density = puff_density
	c.opacity = puff_opacity
	c.decay = puff_decay
	c.drift = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * puff_drift
	get_parent().add_child(c)


func hurt(amount: float) -> void:
	hp -= amount
	if hp <= 0.0:
		if player != null:
			player.coins += value
		queue_free()


func _draw() -> void:
	if kind == Kind.BONG:
		# slumped on the floor
		draw_circle(Vector2.ZERO, radius, color)
		draw_circle(Vector2(0.0, -radius * 0.55), radius * 0.55, color.lightened(0.22))
		draw_arc(Vector2.ZERO, contact_radius, 0.0, TAU, 32, Color(0.85, 0.28, 0.24, 0.22), 1.0)
		return
	if kind == Kind.CIGAR:
		draw_circle(Vector2.ZERO, radius, color)
		draw_circle(Vector2(0.0, -radius * 0.5), radius * 0.6, color.lightened(0.18))
		if lit:
			draw_circle(Vector2(radius * 0.85, -radius * 0.5), 5.0, Color("ff8a3d"))
		else:
			draw_arc(Vector2.ZERO, radius + 8.0, 0.0, TAU, 32, Color("ff5a4a"), 2.0)
		draw_rect(Rect2(-radius, radius + 6.0, radius * 2.0 * (hp / 320.0), 4.0), Color("c25e57"))
		return
	draw_circle(Vector2.ZERO, radius, color)
	draw_circle(Vector2(radius * 0.7, -radius * 0.7), radius * 0.36, color.lightened(0.35))
