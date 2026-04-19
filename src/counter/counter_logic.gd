extends Node

const COUNTER = preload("uid://cs5lr50tom8xo")

@onready var good: Label = $MarginContainer/VBoxContainer/Good
@onready var evil: Label = $MarginContainer/VBoxContainer/Evil

func _process(_delta: float) -> void:
	good.text = "Good: %s" % COUNTER.good
	evil.text = "Evil: %s" % COUNTER.evil
