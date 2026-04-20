extends TextureRect

@export var normal_texture: Texture2D
@export var hover_texture: Texture2D
@export_file("*.tscn") var target_scene_path := "res://scenes/main_scene.tscn"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_set_normal_texture()


func _gui_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null:
		return
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return

	accept_event()
	get_tree().change_scene_to_file(target_scene_path)


func _on_mouse_entered() -> void:
	if hover_texture != null:
		texture = hover_texture


func _on_mouse_exited() -> void:
	_set_normal_texture()


func _set_normal_texture() -> void:
	if normal_texture != null:
		texture = normal_texture
