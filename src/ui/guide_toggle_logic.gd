extends Control

@export var guide_texture: Texture2D
@export var icon_path: NodePath = NodePath("..")
@export var active_texture: Texture2D
@export var guide_size := Vector2(720.0, 540.0)
@export var guide_display_name := "GuideDisplay"
@export var start_highlighted := true
@export_range(0.0, 1.0) var inactive_alpha := 0.75

@onready var icon: TextureRect = get_node_or_null(icon_path) as TextureRect

var guide_display: TextureRect
var is_open := false
var normal_texture: Texture2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	if icon == null:
		push_warning("guide_toggle_logic.gd: guide icon TextureRect node not found.")
		return

	normal_texture = icon.texture
	if normal_texture == null:
		normal_texture = active_texture

	gui_input.connect(_on_gui_input)

	if start_highlighted:
		_set_icon_active(true)
	else:
		_set_open(false)


func _on_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return

	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return

	_set_open(!is_open)


func _set_open(value: bool) -> void:
	is_open = value
	_set_icon_active(is_open)

	if not is_open and guide_display == null:
		return

	var display := _get_or_create_guide_display()
	if display == null:
		return

	display.visible = is_open


func _set_icon_active(value: bool) -> void:
	if icon == null:
		return

	if value and active_texture != null:
		icon.texture = active_texture
		icon.modulate.a = 1.0
		return

	icon.texture = normal_texture
	icon.modulate.a = inactive_alpha if normal_texture == active_texture else 1.0


func _get_or_create_guide_display() -> TextureRect:
	if guide_display != null and is_instance_valid(guide_display):
		return guide_display

	var current_scene := get_tree().current_scene
	if current_scene == null:
		return null

	var ui_root := current_scene.get_node_or_null("CanvasLayer/UIRoot") as Control
	if ui_root == null:
		push_warning("guide_toggle_logic.gd: CanvasLayer/UIRoot node not found.")
		return null

	guide_display = ui_root.get_node_or_null(guide_display_name) as TextureRect
	if guide_display == null:
		guide_display = TextureRect.new()
		guide_display.name = guide_display_name
		guide_display.unique_name_in_owner = true
		ui_root.add_child(guide_display)

	guide_display.texture = guide_texture
	guide_display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	guide_display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	guide_display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	guide_display.z_index = 500
	_center_guide_display()

	return guide_display


func _center_guide_display() -> void:
	if guide_display == null:
		return

	guide_display.anchor_left = 0.5
	guide_display.anchor_top = 0.5
	guide_display.anchor_right = 0.5
	guide_display.anchor_bottom = 0.5
	guide_display.offset_left = -guide_size.x * 0.5
	guide_display.offset_top = -guide_size.y * 0.5
	guide_display.offset_right = guide_size.x * 0.5
	guide_display.offset_bottom = guide_size.y * 0.5
