extends AnimatedSprite2D

@onready var gnome_gome: AnimatedSprite2D = $"."

func _ready() -> void:
	gnome_gome.play("idle")
