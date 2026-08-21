class_name HUD
extends CanvasLayer

var player: Player
var waves: WaveManager
var _c: Control


func _ready() -> void:
	layer = 10
	_c = Control.new()
	_c.set_anchors_preset(Control.PRESET_FULL_RECT)
	_c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_c.draw.connect(_on_draw)
	add_child(_c)


func _process(_delta: float) -> void:
	if _c != null:
		_c.queue_redraw()


func _on_draw() -> void:
	if player == null or waves == null:
		return
	var f := ThemeDB.fallback_font
	var muted := Color("8f9ba5")
	var white := Color("e9eef1")
	var teal := Color("7fe3d4")

	_c.draw_string(f, Vector2(24, 34), "BREATH", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, muted)
	_c.draw_rect(Rect2(24, 42, 220, 10), Color("222a33"))
	var pct := clampf(player.breath / player.max_breath, 0.0, 1.0)
	_c.draw_rect(Rect2(24, 42, 220.0 * pct, 10), teal)

	_c.draw_string(f, Vector2(24, 82), player.fan_name(), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, teal)
	_c.draw_string(f, Vector2(24, 104), "COINS  %d" % player.coins, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, muted)

	var label := "WAVE %d" % waves.wave
	if waves.wave == WaveManager.BOSS_WAVE:
		label = "THE DON"
	_c.draw_string(f, Vector2(520, 40), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, white)
	if not waves.shopping and not waves.finished:
		_c.draw_string(f, Vector2(524, 66), "%0.0f" % maxf(waves.wave_time, 0.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, muted)

	if not player.alive:
		_c.draw_string(f, Vector2(455, 320), "OUT OF BREATH", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("c25e57"))
		return

	if waves.finished:
		_c.draw_string(f, Vector2(430, 320), "SLICE COMPLETE", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, teal)
		return

	if waves.shopping:
		_c.draw_rect(Rect2(330, 240, 500, 170), Color(0.04, 0.06, 0.08, 0.93))
		_c.draw_string(f, Vector2(356, 278), "PICK ONE", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, white)
		_c.draw_string(f, Vector2(356, 318), "1    KILL    +4 damage", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("ffe9a8"))
		var next_fan: String = player.FAN_TIERS[mini(player.fan_tier + 1, player.FAN_TIERS.size() - 1)]
		_c.draw_string(f, Vector2(356, 348), "2    CLEAR   upgrade to %s" % next_fan, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, teal)
		_c.draw_string(f, Vector2(356, 378), "3    LUNGS   +15 max breath", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("f2a33c"))
