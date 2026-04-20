extends Node2D

@export_node_path("TextureRect") var background_path: NodePath = NodePath("TextureRect")

@onready var background: TextureRect = get_node_or_null(background_path) as TextureRect


func _ready() -> void:
	get_viewport().size_changed.connect(_resize_to_viewport)
	_resize_to_viewport.call_deferred()


func _resize_to_viewport() -> void:
	if background == null:
		return

	var viewport_size := get_viewport_rect().size
	var half_viewport_size := viewport_size * 0.5

	background.anchor_left = 0.0
	background.anchor_top = 0.0
	background.anchor_right = 0.0
	background.anchor_bottom = 0.0
	background.offset_left = -half_viewport_size.x
	background.offset_top = -half_viewport_size.y
	background.offset_right = half_viewport_size.x
	background.offset_bottom = half_viewport_size.y
