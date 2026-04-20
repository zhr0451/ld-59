extends Panel

@export var slide_duration := 0.25
@export var hidden_padding := 24.0

var is_open := false
var shown_position := Vector2.ZERO
var hidden_position := Vector2.ZERO
var slide_tween: Tween


func _ready() -> void:
	shown_position = position
	hidden_position = shown_position - Vector2(size.x + hidden_padding, 0.0)
	position = hidden_position
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_open(value: bool) -> void:
	if is_open == value:
		return

	is_open = value
	mouse_filter = Control.MOUSE_FILTER_STOP if is_open else Control.MOUSE_FILTER_IGNORE

	if slide_tween != null:
		slide_tween.kill()

	var target := shown_position if is_open else hidden_position

	slide_tween = create_tween()
	slide_tween.set_trans(Tween.TRANS_CUBIC)
	slide_tween.set_ease(Tween.EASE_OUT)
	slide_tween.tween_property(self, "position", target, slide_duration)


func toggle_open() -> void:
	set_open(!is_open)
