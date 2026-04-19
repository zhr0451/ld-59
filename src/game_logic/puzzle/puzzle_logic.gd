extends Button

@onready var teleport_panel: Panel = %TeleportPanel

func _on_button_up() -> void:
	teleport_panel.toggle_open()
