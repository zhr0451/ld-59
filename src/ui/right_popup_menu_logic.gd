extends Control

@export var slide_duration := 0.25
@export var hidden_padding := 24.0
@export_node_path("Control") var bind_target_path: NodePath
@export var bind_gap := 0.0

var is_open := false
var slide_tween: Tween

var shown_left := 0.0
var shown_right := 0.0

var hidden_left := 0.0
var hidden_right := 0.0


func _ready() -> void:
	await get_tree().process_frame
	_refresh_layout_from_target()

	shown_left = offset_left
	shown_right = offset_right

	var shift := size.x + hidden_padding

	hidden_left = shown_left + shift
	hidden_right = shown_right + shift

	offset_left = hidden_left
	offset_right = hidden_right

	get_viewport().size_changed.connect(_on_viewport_size_changed)


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


func _refresh_layout_from_target() -> bool:
	var bind_target := get_node_or_null(bind_target_path) as Control
	if bind_target == null:
		return false

	global_position = Vector2(
		bind_target.global_position.x - size.x - bind_gap,
		global_position.y
	)
	return true


func _on_viewport_size_changed() -> void:
	call_deferred("_recalculate_positions_after_resize")


func _recalculate_positions_after_resize() -> void:
	var has_bind_target := _refresh_layout_from_target()

	# When the panel is closed, current offsets already point to the hidden state.
	# Only recapture shown offsets from the live layout if the panel is open,
	# or if we can explicitly align it from a bind target.
	if is_open or has_bind_target:
		shown_left = offset_left
		shown_right = offset_right

	var shift := size.x + hidden_padding
	hidden_left = shown_left + shift
	hidden_right = shown_right + shift

	if is_open:
		offset_left = shown_left
		offset_right = shown_right
	else:
		offset_left = hidden_left
		offset_right = hidden_right
