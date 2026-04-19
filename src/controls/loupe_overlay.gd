extends ColorRect

signal world_focus_changed(world_position: Vector2)

@export var lens_radius: float = 120.0
@export var magnification: float = 2.0
@export_node_path("Camera2D") var camera_path: NodePath = NodePath("../../../LocationCamera")
@export_node_path("BaseButton") var toggle_button_path: NodePath = NodePath("DownPanel/Buttons/MarginContainer/Button")

@onready var camera: Camera2D = get_node_or_null(camera_path) as Camera2D
@onready var shader_material: ShaderMaterial = material as ShaderMaterial
@onready var toggle_button: BaseButton = get_node_or_null(toggle_button_path) as BaseButton

var loupe_enabled := false
var world_focus_position := Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	set_process(false)
	_refresh_visuals()


func _process(_delta: float) -> void:
	_update_loupe()


func set_loupe_enabled(value: bool) -> void:
	loupe_enabled = value
	visible = value
	set_process(value)

	_sync_toggle_buttons(value)

	if value:
		_update_loupe()


func is_loupe_enabled() -> bool:
	return loupe_enabled


func get_world_focus_position() -> Vector2:
	return world_focus_position


func _update_loupe() -> void:
	_refresh_visuals()

	var mouse_position := get_viewport().get_mouse_position()
	position = mouse_position - size * 0.5
	_update_shader(mouse_position)
	_update_world_focus(mouse_position)


func _refresh_visuals() -> void:
	size = Vector2.ONE * lens_radius * 2.0


func _update_shader(mouse_position: Vector2) -> void:
	if shader_material == null:
		return

	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	shader_material.set_shader_parameter("lens_center_uv", mouse_position / viewport_size)
	shader_material.set_shader_parameter("lens_radius", lens_radius)
	shader_material.set_shader_parameter("magnification", magnification)


func _update_world_focus(mouse_position: Vector2) -> void:
	if camera == null:
		world_focus_position = mouse_position
		world_focus_changed.emit(world_focus_position)
		return

	var viewport_center := get_viewport_rect().size * 0.5
	var screen_offset := mouse_position - viewport_center

	world_focus_position = camera.get_screen_center_position() + screen_offset / camera.zoom
	world_focus_changed.emit(world_focus_position)


func _sync_toggle_buttons(value: bool) -> void:
	if toggle_button != null and toggle_button.button_pressed != value:
		toggle_button.set_pressed_no_signal(value)

	for button in get_tree().get_nodes_in_group("loupe_toggle_buttons"):
		var toggle := button as BaseButton
		if toggle != null and toggle.button_pressed != value:
			toggle.set_pressed_no_signal(value)
