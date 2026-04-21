extends Node

# true – good ending
# false – bad ending

const BAD_ENDING = preload("uid://c5ryjt2i58n1h")
const GOOD_ENDING = preload("uid://be3ux7u1sf57l")
const PORTAL_FRAMES = preload("res://assets/animations/portal/portal.tres")
const BAD_PORTAL_FRAMES = preload("res://assets/animations/portal/portal_bad.tres")
const BAD_PORTAL_RAW_DIR = "res://assets/animations/portal/portal_bad_raw"

@export_node_path("Node2D") var map_path: NodePath = NodePath("../WorldRoot/Map")
@export_node_path("Camera2D") var camera_path: NodePath = NodePath("../LocationCamera")
@export var screen_margin := Vector2(600.0, 600.0)
@export var spawn_delay_seconds := 2.0
@export var portal_duration_seconds := 1.2
@export var portal_scale := Vector2(0.35, 0.35)
@export var portal_animation_name: StringName = &"portal"
@export var bad_portal_animation_name: StringName = &"portal"
@export var bad_portal_speed := 25.0

var counter = preload("uid://cs5lr50tom8xo")
var final: bool
var active_character: Area2D = null
var last_spawned_character: Area2D = null
var spawn_request_id := 0
var cached_bad_portal_frames: SpriteFrames = null


func _ready() -> void:
	randomize()
	var map := _get_map()
	if map == null:
		return

	for character in _get_map_characters(map):
		_set_character_active(character, false)

	call_deferred("show_random_character", false)


func _process(_delta: float) -> void:
	if counter.good >= 10:
		final = true
		if final == true:
			get_tree().change_scene_to_packed(GOOD_ENDING)

	if counter.evil >= 10:
		final = false
		if final == false:
			get_tree().change_scene_to_packed(BAD_ENDING)


func show_random_character(use_delay := true) -> void:
	_transition_to_random_character(active_character, PORTAL_FRAMES, portal_animation_name, use_delay)


func show_failed_character(character: Area2D = null, use_delay := true) -> void:
	var failed_character := character
	if failed_character == null:
		failed_character = active_character

	_transition_to_random_character(failed_character, _get_bad_portal_frames(), bad_portal_animation_name, use_delay)


func _transition_to_random_character(previous_character: Area2D, portal_frames: SpriteFrames, animation_name: StringName, use_delay: bool) -> void:
	var map := _get_map()
	if map == null:
		push_warning("scene_changer.gd: map node not found.")
		return

	var characters := _get_map_characters(map)
	if characters.is_empty():
		push_warning("scene_changer.gd: no Area2D characters found under map.")
		return

	_spawn_portal_for_character(map, previous_character, portal_frames, animation_name)

	for character in characters:
		_set_character_active(character, false)

	active_character = null
	spawn_request_id += 1
	var current_request_id := spawn_request_id

	if use_delay and spawn_delay_seconds > 0.0:
		await get_tree().create_timer(spawn_delay_seconds).timeout
		if current_request_id != spawn_request_id:
			return
		if not is_inside_tree() or not is_instance_valid(map):
			return

	active_character = _pick_next_character(characters, previous_character)
	last_spawned_character = active_character
	active_character.position = _get_spawn_position(map) - _get_character_offset(active_character)
	_set_character_active(active_character, true)


func _spawn_portal_for_character(map: Node2D, character: Area2D, portal_frames: SpriteFrames, animation_name: StringName) -> void:
	if character == null:
		return
	if portal_frames == null:
		push_warning("scene_changer.gd: portal frames resource is not configured.")
		return

	var resolved_animation_name := _get_portal_animation_name(portal_frames, animation_name)
	if resolved_animation_name == &"":
		push_warning("scene_changer.gd: portal frames resource has no animations.")
		return

	var portal := AnimatedSprite2D.new()
	portal.name = "TeleportPortal"
	portal.sprite_frames = portal_frames
	portal.animation = resolved_animation_name
	portal.scale = portal_scale
	portal.z_index = 100
	portal.position = character.position + _get_character_offset(character)

	map.add_child(portal)
	portal.play()
	_free_portal_after_delay(portal)


func _get_portal_animation_name(portal_frames: SpriteFrames, animation_name: StringName) -> StringName:
	if portal_frames.has_animation(animation_name) and portal_frames.get_frame_count(animation_name) > 0:
		return animation_name

	var animation_names := portal_frames.get_animation_names()
	for portal_animation_name_candidate in animation_names:
		var candidate := StringName(portal_animation_name_candidate)
		if portal_frames.get_frame_count(candidate) > 0:
			return candidate

	return &""


func _get_bad_portal_frames() -> SpriteFrames:
	if _get_portal_animation_name(BAD_PORTAL_FRAMES, bad_portal_animation_name) != &"":
		return BAD_PORTAL_FRAMES
	if cached_bad_portal_frames != null:
		return cached_bad_portal_frames

	var frames := SpriteFrames.new()
	frames.add_animation(bad_portal_animation_name)
	frames.set_animation_loop(bad_portal_animation_name, true)
	frames.set_animation_speed(bad_portal_animation_name, bad_portal_speed)

	var file_names := DirAccess.get_files_at(BAD_PORTAL_RAW_DIR)
	file_names.sort()

	for file_name in file_names:
		if file_name.get_extension().to_lower() != "png":
			continue

		var texture := load("%s/%s" % [BAD_PORTAL_RAW_DIR, file_name]) as Texture2D
		if texture != null:
			frames.add_frame(bad_portal_animation_name, texture)

	if frames.get_frame_count(bad_portal_animation_name) == 0:
		push_warning("scene_changer.gd: portal_bad.tres is empty and no fallback raw frames were loaded.")
		return BAD_PORTAL_FRAMES

	cached_bad_portal_frames = frames
	return cached_bad_portal_frames


func _free_portal_after_delay(portal: AnimatedSprite2D) -> void:
	await get_tree().create_timer(portal_duration_seconds).timeout

	if is_instance_valid(portal):
		portal.queue_free()


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
		if character != previous_character and character != last_spawned_character:
			available_characters.append(character)

	if available_characters.is_empty():
		for character in characters:
			if character != previous_character:
				available_characters.append(character)

	if available_characters.is_empty():
		return characters[randi() % characters.size()]

	return available_characters[randi() % available_characters.size()]
