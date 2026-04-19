extends Button

@onready var teleport_panel: Panel = %TeleportPanel
@onready var scene_changer: Node = %SceneChanger

func _on_button_up() -> void:
	teleport_panel.toggle_open()

	if scene_changer != null and scene_changer.has_method("show_random_character"):
		scene_changer.show_random_character()
