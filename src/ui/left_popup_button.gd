extends Button

@export_node_path("Control") var panel_path: NodePath = NodePath("../PopUpPanel")
@onready var panel = get_node_or_null(panel_path)


func _ready() -> void:
	if panel_path.is_empty():
		push_error("popup_button.gd: panel_path is empty.")
		return

	if panel == null:
		push_error("popup_button.gd: Control not found at path '%s'." % panel_path)
		return

	if not panel.has_method("toggle_open"):
		push_error("popup_button.gd: Node at path '%s' does not implement toggle_open()." % panel_path)


func _on_button_up() -> void:
	if panel == null:
		push_error("popup_button.gd: Cannot toggle popup because panel was not found at '%s'." % panel_path)
		return

	if not panel.has_method("toggle_open"):
		push_error("popup_button.gd: Cannot toggle popup because node at '%s' has no toggle_open()." % panel_path)
		return

	panel.toggle_open()
