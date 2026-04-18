extends Button

enum {IDLE, LEFT, RIGHT}

var current_state = IDLE

func _process(_delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		current_state = LEFT
	elif Input.is_action_pressed("move_right"):
		current_state = RIGHT
	else:
		current_state = IDLE

	if current_state == LEFT:
		print("Left")
	elif current_state == RIGHT:
		print("Right")
