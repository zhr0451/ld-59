extends Node

# true – good ending
# false – bad ending

const BAD_ENDING = preload("uid://c5ryjt2i58n1h")
const GOOD_ENDING = preload("uid://be3ux7u1sf57l")

var counter = preload("uid://cs5lr50tom8xo")
var final: bool 

func _process(_delta: float) -> void:
	if counter.good >= 10:
		final = true
		if final == true:
			get_tree().change_scene_to_packed(GOOD_ENDING)
	if counter.evil >= 10:
		final = false
		if final == false:
			get_tree().change_scene_to_packed(BAD_ENDING)
