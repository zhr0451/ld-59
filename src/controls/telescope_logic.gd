extends Button

@export_node_path("ColorRect") var loupe_overlay_path: NodePath = NodePath("../../../../LoupeOverlay")

@onready var loupe_overlay: ColorRect = get_node_or_null(loupe_overlay_path) as ColorRect


func _ready() -> void:
	toggle_mode = true


func _on_button_up() -> void:
	if loupe_overlay != null and loupe_overlay.has_method("set_loupe_enabled"):
		loupe_overlay.call("set_loupe_enabled", button_pressed)
