extends Control

@export var fade_duration := 0.15
@export var panel_size := Vector2(524.0, 420.0)

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

	var target_size := panel_size
	if target_size.x <= 0.0 or target_size.y <= 0.0:
		target_size = custom_minimum_size

	offset_left = -target_size.x * 0.5
	offset_top = -target_size.y * 0.5
	offset_right = target_size.x * 0.5
	offset_bottom = target_size.y * 0.5


func _hide_after_fade() -> void:
	if not is_open:
		visible = false


func _on_viewport_size_changed() -> void:
	_center_panel()
