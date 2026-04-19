extends Area2D

@onready var pop_up_panel: Panel = $"../../../CanvasLayer/UIRoot/PopUpPanel"

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Клик по спрайту")
		pop_up_panel.toggle_open()
