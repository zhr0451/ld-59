extends Node

var counter = preload("uid://cs5lr50tom8xo")

@onready var good: Label = get_node_or_null("Good") as Label
@onready var evil: Label = get_node_or_null("Evil") as Label

func _process(_delta: float) -> void:
	if good != null:
		good.text = "%s" % counter.good
	if evil != null:
		evil.text = "%s" % counter.evil
