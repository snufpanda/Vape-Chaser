class_name Bullet
extends Node2D

var dir := Vector2.RIGHT
var speed := 640.0
var damage := 12.0
var life := 1.6
var hostile := false


func _ready() -> void:
	z_index = 6


func _process(delta: float) -> void:
	position += dir * speed * delta
	life -= delta
	if life <= 0.0:
		queue_free()
		return

	if hostile:
		var p := get_tree().get_first_node_in_group("player") as Player
		if p != null and p.alive and position.distance_to(p.position) < Player.RADIUS + 4.0:
			p.hurt(damage)
			queue_free()
			return
	else:
		for n in get_tree().get_nodes_in_group("enemies"):
			var e := n as Enemy
			if position.distance_to(e.position) < e.radius + 4.0:
				e.hurt(damage)
				queue_free()
				return
	queue_redraw()


func _draw() -> void:
	if hostile:
		draw_circle(Vector2.ZERO, 4.5, Color("ff5a4a"))
	else:
		draw_circle(Vector2.ZERO, 3.0, Color("ffe9a8"))
