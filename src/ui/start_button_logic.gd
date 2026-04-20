extends TextureRect

@export var normal_texture: Texture2D
@export var hover_texture: Texture2D
@export_file("*.tscn") var target_scene_path := "res://scenes/main_scene.tscn"

var transition_started := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_set_normal_texture()


func _gui_input(event: InputEvent) -> void:
	if transition_started:
		return

	var mouse_event := event as InputEventMouseButton
	if mouse_event == null:
		return
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return

	accept_event()
	transition_started = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_current_scene_visible(false)

	var error := get_tree().change_scene_to_file(target_scene_path)
	if error != OK:
		push_error("start_button_logic.gd: failed to change scene to '%s'. Error: %s" % [target_scene_path, error])
		transition_started = false
		mouse_filter = Control.MOUSE_FILTER_STOP
		_set_current_scene_visible(true)


func _on_mouse_entered() -> void:
	if hover_texture != null:
		texture = hover_texture


func _on_mouse_exited() -> void:
	_set_normal_texture()


func _set_normal_texture() -> void:
	if normal_texture != null:
		texture = normal_texture


func _set_current_scene_visible(value: bool) -> void:
	var current_scene := get_tree().current_scene as CanvasItem
	if current_scene != null:
		current_scene.visible = value
