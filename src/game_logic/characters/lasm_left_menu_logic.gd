extends Area2D

@onready var pop_up_panel = $"../../../CanvasLayer/UIRoot/PopUpPanel"
@onready var loupe_overlay: ColorRect = $"../../../CanvasLayer/UIRoot/LoupeOverlay"
@onready var name_label: Label = get_node_or_null("../../../CanvasLayer/UIRoot/PopUpPanel/TextureRect/NameLabel") as Label
@onready var message_lable: Label = get_node_or_null("../../../CanvasLayer/UIRoot/PopUpPanel/TextureRect/MessageLable") as Label
@onready var texture_icon: TextureRect = get_node_or_null("../../../CanvasLayer/UIRoot/PopUpPanel/TextureRect/TextureIcon") as TextureRect
@onready var quest_panel: Control = %QuestPanel
@onready var quest_logic: Node = %QuestLogic

const LASM = preload("uid://bn25os8041ksj")

func _input_event(_viewport, event, _shape_idx):
	if loupe_overlay.is_loupe_enabled() == true:
		if event is InputEventMouseButton and event.pressed:
			_fill_popup(LASM.name, LASM.message, LASM.icon)
			loupe_overlay.set_loupe_enabled(false)
			pop_up_panel.set_open(true)
			quest_panel.set_open(true)
			if quest_logic.has_method("start_puzzle"):
				quest_logic.start_puzzle(LASM.name, LASM.questions, self)


func _fill_popup(character_name: String, character_message: String, character_icon: Texture2D) -> void:
	if name_label != null:
		name_label.text = character_name
	if message_lable != null:
		message_lable.text = character_message
	if texture_icon != null:
		texture_icon.texture = character_icon
