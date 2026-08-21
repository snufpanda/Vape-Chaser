extends Node2D

const ARENA := Vector2(1152, 648)

func _ready() -> void:
	var player := Player.new()
	player.arena = ARENA
	player.position = ARENA * 0.5
	add_child(player)

	var waves := WaveManager.new()
	waves.player = player
	waves.arena = ARENA
	add_child(waves)

	var hud := HUD.new()
	hud.player = player
	hud.waves = waves
	add_child(hud)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, ARENA), Color("10141a"))
	var grid := Color("1b222b")
	var x := 0.0
	while x < ARENA.x:
		draw_line(Vector2(x, 0.0), Vector2(x, ARENA.y), grid, 1.0)
		x += 96.0
	var y := 0.0
	while y < ARENA.y:
		draw_line(Vector2(0.0, y), Vector2(ARENA.x, y), grid, 1.0)
		y += 96.0
