extends Node

const COUNTER = preload("uid://cs5lr50tom8xo")

@onready var good: Label = $MarginContainer/VBoxContainer/Good
@onready var evil: Label = $MarginContainer/VBoxContainer/Evil
@onready var chaos: Label = $MarginContainer/VBoxContainer/Chaos

func _process(_delta: float) -> void:
	good.text = "Good: %s" % COUNTER.good
	evil.text = "Evil: %s" % COUNTER.evil
	chaos.text = "Chaos: %s" % COUNTER.chaos
