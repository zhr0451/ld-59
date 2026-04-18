extends Camera2D

@export var move_speed: float = 600.0
@export_node_path("Sprite2D") var map_path: NodePath = NodePath("../WorldRoot/Map")

var fixed_y: float
var min_x: float = -INF
var max_x: float = INF


func _ready() -> void:
	make_current()
	fixed_y = global_position.y

	get_viewport().size_changed.connect(_refresh_camera_setup)
	_refresh_camera_setup()
	_clamp_to_world()


func _process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	global_position.x += direction * move_speed * delta
	global_position.y = fixed_y
	_clamp_to_world()


func _refresh_camera_setup() -> void:
	var map := get_node_or_null(map_path) as Sprite2D
	if map == null or map.texture == null:
		zoom = Vector2.ONE
		min_x = -INF
		max_x = INF
		return

	var map_size := map.texture.get_size() * map.scale.abs()
	var viewport_size := get_viewport_rect().size
	_fit_zoom_to_map(map_size, viewport_size)

	var map_left := map.global_position.x - map_size.x * 0.5
	var map_right := map.global_position.x + map_size.x * 0.5
	var half_view_width := viewport_size.x * 0.5 / zoom.x

	if map_size.x <= half_view_width * 2.0:
		min_x = map.global_position.x
		max_x = map.global_position.x
		return

	min_x = map_left + half_view_width
	max_x = map_right - half_view_width


func _fit_zoom_to_map(map_size: Vector2, viewport_size: Vector2) -> void:
	if map_size.x <= 0.0 or map_size.y <= 0.0:
		zoom = Vector2.ONE
		return

	var target_zoom := maxf(
		viewport_size.x / map_size.x,
		viewport_size.y / map_size.y
	)

	zoom = Vector2.ONE * target_zoom


func _clamp_to_world() -> void:
	global_position.x = clampf(global_position.x, min_x, max_x)
