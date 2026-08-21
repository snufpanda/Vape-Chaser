class_name Cloud
extends Node2D

# Drawn ABOVE enemies on purpose (z_index 10 vs 5).
# That one line is the hook: you cannot see what is sitting in the smoke.
#
# TWO SEPARATE PROPERTIES, and this is the important part:
#   opacity = how much it BLINDS you
#   density = how much it CHOKES you
# Vape smoke is all opacity, zero density. It cannot kill you.
# It just makes you walk into something that can.

var radius := 70.0
var density := 0.0
var opacity := 0.5
var drift := Vector2.ZERO
var decay := 3.0


func _ready() -> void:
	z_index = 10
	add_to_group("clouds")


func _process(delta: float) -> void:
	position += drift * delta
	radius -= decay * delta
	if radius <= 3.0:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var a := clampf(opacity, 0.0, 0.95)
	for i in range(5):
		var t := 1.0 - float(i) / 5.0
		draw_circle(Vector2.ZERO, radius * t, Color(0.87, 0.91, 0.93, a * 0.30))
