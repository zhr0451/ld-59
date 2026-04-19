extends Node

# true – good ending
# false – bad ending

const BAD_ENDING = preload("uid://c5ryjt2i58n1h")
const GOOD_ENDING = preload("uid://be3ux7u1sf57l")

@export_node_path("Node2D") var map_path: NodePath = NodePath("../WorldRoot/Map")
@export_node_path("Camera2D") var camera_path: NodePath = NodePath("../LocationCamera")
@export var screen_margin := Vector2(600.0, 600.0)

var counter = preload("uid://cs5lr50tom8xo")
var final: bool
var active_character: Area2D = null


func _ready() -> void:
	randomize()
	var map := _get_map()
	if map != null:
		for character in _get_map_characters(map):
			_set_character_active(character, false)
	call_deferred("show_random_character")


func _process(_delta: float) -> void:
	if counter.good >= 10:
		final = true
		if final == true:
			get_tree().change_scene_to_packed(GOOD_ENDING)

	if counter.evil >= 10:
		final = false
		if final == false:
			get_tree().change_scene_to_packed(BAD_ENDING)


func show_random_character() -> void:
	var map := _get_map()
	if map == null:
		push_warning("scene_changer.gd: map node not found.")
		return

	var characters := _get_map_characters(map)
	if characters.is_empty():
		push_warning("scene_changer.gd: no Area2D characters found under map.")
		return

	var previous_character := active_character

	for character in characters:
		_set_character_active(character, false)

	active_character = _pick_next_character(characters, previous_character)
	active_character.position = _get_spawn_position(map) - _get_character_offset(active_character)
	_set_character_active(active_character, true)


func _get_map() -> Node2D:
	var map := get_node_or_null(map_path) as Node2D
	if map != null:
		return map

	var current_scene := get_tree().current_scene
	if current_scene == null:
		return null

	return current_scene.get_node_or_null("WorldRoot/Map") as Node2D


func _get_map_characters(map: Node2D) -> Array[Area2D]:
	var characters: Array[Area2D] = []

	for child in map.get_children():
		if child is Area2D:
			characters.append(child)

	return characters


func _set_character_active(character: Area2D, value: bool) -> void:
	character.monitoring = value
	character.monitorable = value
	character.input_pickable = value

	for child in character.get_children():
		if child is CollisionShape2D:
			child.disabled = not value
		elif child is CanvasItem:
			child.visible = value


func _get_spawn_position(map: Node2D) -> Vector2:
	var map_sprite := map as Sprite2D

	if map_sprite == null or map_sprite.texture == null:
		return Vector2.ZERO

	var half_map_size := map_sprite.texture.get_size() * 0.5
	var safe_margin_x := minf(screen_margin.x, maxf(half_map_size.x - 32.0, 0.0))
	var safe_margin_y := minf(screen_margin.y, maxf(half_map_size.y - 32.0, 0.0))
	var min_x := -half_map_size.x + safe_margin_x
	var max_x := half_map_size.x - safe_margin_x
	var min_y := -half_map_size.y + safe_margin_y
	var max_y := half_map_size.y - safe_margin_y

	return Vector2(
		randf_range(min_x, max_x),
		randf_range(min_y, max_y)
	)


func _get_character_offset(character: Area2D) -> Vector2:
	var offsets: Array[Vector2] = []

	for child in character.get_children():
		if child is Node2D:
			offsets.append(child.position)

	if offsets.is_empty():
		return Vector2.ZERO

	var total := Vector2.ZERO
	for offset in offsets:
		total += offset

	return total / float(offsets.size())


func _pick_next_character(characters: Array[Area2D], previous_character: Area2D) -> Area2D:
	if characters.size() == 1:
		return characters[0]

	var available_characters: Array[Area2D] = []

	for character in characters:
		if character != previous_character:
			available_characters.append(character)

	if available_characters.is_empty():
		return characters[randi() % characters.size()]

	return available_characters[randi() % available_characters.size()]
