extends Control

@export var left_action := "move_left"
@export var right_action := "move_right"
@export var left_animation := "left"
@export var right_animation := "right"
@export var sprite_scale := Vector2.ZERO

@onready var valve_sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_direction := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_center_sprite)
	valve_sprite.speed_scale = 1.0
	if sprite_scale == Vector2.ZERO:
		sprite_scale = valve_sprite.scale
	_center_sprite()
	_stop_valve()


func _process(_delta: float) -> void:
	var direction := 0
	if Input.is_action_pressed(left_action):
		direction -= 1
	if Input.is_action_pressed(right_action):
		direction += 1

	if direction == current_direction:
		return

	current_direction = direction

	if current_direction < 0:
		_play_valve(left_animation)
	elif current_direction > 0:
		_play_valve(right_animation)
	else:
		_stop_valve()


func _center_sprite() -> void:
	if valve_sprite == null:
		return

	valve_sprite.position = size * 0.5
	valve_sprite.scale = sprite_scale


func _play_valve(animation_name: String) -> void:
	if valve_sprite == null:
		return

	if valve_sprite.animation != animation_name:
		valve_sprite.play(animation_name)
	elif not valve_sprite.is_playing():
		valve_sprite.play()


func _stop_valve() -> void:
	if valve_sprite == null:
		return

	valve_sprite.pause()
