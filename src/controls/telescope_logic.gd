extends TextureRect

@export_node_path("ColorRect") var loupe_overlay_path: NodePath = NodePath("../LoupeOverlay")
@export_node_path("Control") var click_area_path: NodePath = NodePath("ClickArea")
@export var inactive_texture: Texture2D
@export var active_texture: Texture2D

@onready var loupe_overlay: ColorRect = get_node_or_null(loupe_overlay_path) as ColorRect
@onready var click_area: Control = get_node_or_null(click_area_path) as Control

var button_pressed := false
var is_hovered := false


func _ready() -> void:
	add_to_group("loupe_toggle_buttons")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_setup_click_area()
	_update_texture()


func _gui_input(event: InputEvent) -> void:
	_handle_click_event(event)


func _setup_click_area() -> void:
	if click_area == null:
		mouse_filter = Control.MOUSE_FILTER_STOP
		mouse_entered.connect(_on_hover_started)
		mouse_exited.connect(_on_hover_ended)
		return

	click_area.mouse_filter = Control.MOUSE_FILTER_STOP
	click_area.gui_input.connect(_on_click_area_gui_input)
	click_area.mouse_entered.connect(_on_hover_started)
	click_area.mouse_exited.connect(_on_hover_ended)


func _on_click_area_gui_input(event: InputEvent) -> void:
	_handle_click_event(event)


func _handle_click_event(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event != null and mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
		accept_event()
		set_loupe_button_pressed(!button_pressed)
		_apply_loupe_state()


func _on_button_up() -> void:
	set_loupe_button_pressed(!button_pressed)
	_apply_loupe_state()


func set_loupe_button_pressed(value: bool) -> void:
	button_pressed = value
	_update_texture()


func _apply_loupe_state() -> void:
	if loupe_overlay != null and loupe_overlay.has_method("set_loupe_enabled"):
		loupe_overlay.call("set_loupe_enabled", button_pressed)


func _update_texture() -> void:
	if (button_pressed or is_hovered) and active_texture != null:
		texture = active_texture
	elif inactive_texture != null:
		texture = inactive_texture


func _on_hover_started() -> void:
	is_hovered = true
	_update_texture()


func _on_hover_ended() -> void:
	is_hovered = false
	_update_texture()
