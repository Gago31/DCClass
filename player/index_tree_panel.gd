extends PanelContainer

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"camera_zoom_in"):
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"camera_zoom_out"):
		get_viewport().set_input_as_handled()
