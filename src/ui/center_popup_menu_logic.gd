extends Panel

@export var fade_duration := 0.15

var is_open := false
var fade_tween: Tween


func _ready() -> void:
	_center_panel()
	visible = false
	modulate.a = 0.0
	get_viewport().size_changed.connect(_on_viewport_size_changed)


func set_open(value: bool) -> void:
	if is_open == value:
		return

	is_open = value

	if fade_tween:
		fade_tween.kill()

	if is_open:
		_center_panel()
		visible = true

	fade_tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_CUBIC)
	fade_tween.set_ease(Tween.EASE_OUT)
	fade_tween.tween_property(self, "modulate:a", 1.0 if is_open else 0.0, fade_duration)

	if not is_open:
		fade_tween.finished.connect(_hide_after_fade)


func toggle_open() -> void:
	set_open(!is_open)


func _center_panel() -> void:
	anchor_left = 0.5
	anchor_top = 0.5
	anchor_right = 0.5
	anchor_bottom = 0.5

	var panel_size := size
	if panel_size.x <= 0.0 or panel_size.y <= 0.0:
		panel_size = custom_minimum_size

	offset_left = -panel_size.x * 0.5
	offset_top = -panel_size.y * 0.5
	offset_right = panel_size.x * 0.5
	offset_bottom = panel_size.y * 0.5


func _hide_after_fade() -> void:
	if not is_open:
		visible = false


func _on_viewport_size_changed() -> void:
	_center_panel()
