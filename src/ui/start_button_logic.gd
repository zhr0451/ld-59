extends TextureRect

@export var normal_texture: Texture2D
@export var hover_texture: Texture2D
@export_file("*.tscn") var target_scene_path := "res://scenes/main_scene.tscn"
@export_node_path("Control") var loading_indicator_path: NodePath = NodePath("../LoadingIndicator")

@onready var loading_indicator: Control = get_node_or_null(loading_indicator_path) as Control

var transition_started := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	set_process(false)
	_set_loading_visible(false)
	_set_normal_texture()


func _process(_delta: float) -> void:
	var progress: Array = []
	var status := ResourceLoader.load_threaded_get_status(target_scene_path, progress)

	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		_update_loading_progress(progress)
		return

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var scene := ResourceLoader.load_threaded_get(target_scene_path) as PackedScene
		_change_to_loaded_scene(scene)
		return

	_handle_load_error(status)


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
	_set_loading_visible(true)

	var error := ResourceLoader.load_threaded_request(target_scene_path)
	if error != OK:
		_handle_request_error(error)
		return

	set_process(true)


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


func _set_loading_visible(value: bool) -> void:
	if loading_indicator != null:
		loading_indicator.visible = value


func _update_loading_progress(progress: Array) -> void:
	if loading_indicator == null or progress.is_empty():
		return

	var progress_bar := loading_indicator.get_node_or_null("ProgressBar") as ProgressBar
	if progress_bar != null:
		progress_bar.value = float(progress[0]) * 100.0


func _change_to_loaded_scene(scene: PackedScene) -> void:
	set_process(false)

	if scene == null:
		_handle_load_error(ResourceLoader.THREAD_LOAD_FAILED)
		return

	_set_current_scene_visible(false)
	var error := get_tree().change_scene_to_packed(scene)
	if error != OK:
		push_error("start_button_logic.gd: failed to change scene to '%s'. Error: %s" % [target_scene_path, error])
		_restore_after_error()


func _handle_request_error(error: int) -> void:
	push_error("start_button_logic.gd: failed to start loading '%s'. Error: %s" % [target_scene_path, error])
	_restore_after_error()


func _handle_load_error(status: int) -> void:
	push_error("start_button_logic.gd: failed to load '%s'. Status: %s" % [target_scene_path, status])
	_restore_after_error()


func _restore_after_error() -> void:
	set_process(false)
	transition_started = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_set_loading_visible(false)
	_set_current_scene_visible(true)
