extends Area2D

@onready var pop_up_panel: Panel = $"../../../CanvasLayer/UIRoot/PopUpPanel"
@onready var loupe_overlay: ColorRect = $"../../../CanvasLayer/UIRoot/LoupeOverlay"
@onready var name_label: Label = %NameLabel
@onready var message_lable: Label = %MessageLable
@onready var texture_icon: TextureRect = %TextureIcon
@onready var quest_panel: Panel = %QuestPanel
@onready var quest_logic: Node = %QuestLogic

const GNOME_GOME = preload("uid://slkvadx6r606")

func _input_event(_viewport, event, _shape_idx):
	if loupe_overlay.is_loupe_enabled() == true:
		if event is InputEventMouseButton and event.pressed:
			name_label.set_text(GNOME_GOME.name)
			message_lable.set_text(GNOME_GOME.message)
			texture_icon.set_texture(GNOME_GOME.icon)
			loupe_overlay.set_loupe_enabled(false)
			pop_up_panel.set_open(true)
			quest_panel.set_open(true)
			if quest_logic.has_method("start_puzzle"):
				quest_logic.start_puzzle(GNOME_GOME.name, GNOME_GOME.questions)
