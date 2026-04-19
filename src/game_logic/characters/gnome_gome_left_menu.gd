extends Area2D

@onready var pop_up_panel: Panel = $"../../../CanvasLayer/UIRoot/PopUpPanel"
@onready var loupe_overlay: ColorRect = $"../../../CanvasLayer/UIRoot/LoupeOverlay"
@onready var name_label: Label = %NameLabel
@onready var message_lable: Label = %MessageLable
@onready var texture_icon: TextureRect = %TextureIcon
@onready var quest_panel: Panel = %QuestPanel

const GNOME_GOME = preload("uid://slkvadx6r606")

func _input_event(_viewport, event, _shape_idx):
	if loupe_overlay.is_loupe_enabled() == true:
		if event is InputEventMouseButton and event.pressed:
			print("Клик по спрайту")
			name_label.set_text(GNOME_GOME.name)
			message_lable.set_text(GNOME_GOME.message)
			texture_icon.set_texture(GNOME_GOME.icon)
			pop_up_panel.toggle_open()
			quest_panel.toggle_open()
