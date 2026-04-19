extends Panel

@export var slide_duration := 0.25
@export var hidden_padding := 24.0

var is_open := false
var slide_tween: Tween

var shown_left := 0.0
var shown_right := 0.0

var hidden_left := 0.0
var hidden_right := 0.0


func _ready() -> void:
	await get_tree().process_frame

	# текущее положение (видимое)
	shown_left = offset_left
	shown_right = offset_right

	var shift := size.x + hidden_padding

	# скрытое положение (сдвиг вправо)
	hidden_left = shown_left + shift
	hidden_right = shown_right + shift

	# стартуем скрытой
	offset_left = hidden_left
	offset_right = hidden_right


func set_open(value: bool) -> void:
	if is_open == value:
		return

	is_open = value

	if slide_tween:
		slide_tween.kill()

	var target_left := shown_left if is_open else hidden_left
	var target_right := shown_right if is_open else hidden_right

	slide_tween = create_tween()
	slide_tween.set_trans(Tween.TRANS_CUBIC)
	slide_tween.set_ease(Tween.EASE_OUT)

	slide_tween.tween_property(self, "offset_left", target_left, slide_duration)
	slide_tween.parallel().tween_property(self, "offset_right", target_right, slide_duration)


func toggle_open() -> void:
	set_open(!is_open)
