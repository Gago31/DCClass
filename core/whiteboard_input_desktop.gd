class_name WhiteboardInputDesktop
extends WhiteboardInputController


func _handle_screen_dragging(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		_dragging = event.is_pressed()
	elif event is InputEventMouseMotion and _dragging:
		get_viewport().set_input_as_handled()

		if not _warped:
			camera.user_controlled = true
			camera.position -= (event as InputEventMouseMotion).relative
		else:
			_warped = false

		var mouse_pos: Vector2 = event.global_position
		var view := get_global_rect().grow(WARP_OFFSET)
		
		mouse_pos.x = wrapf(mouse_pos.x, view.position.x, view.end.x)
		mouse_pos.y = wrapf(mouse_pos.y, view.position.y, view.end.y)
		if mouse_pos != (event as InputEventMouseMotion).global_position:
			_warped = true
		Input.warp_mouse(mouse_pos)
