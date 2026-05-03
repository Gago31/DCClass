class_name ClassRootWidget
extends ClassGroupWidget

signal playtime_changed

func jump_to_widget(widget: Widget) -> bool:
	WhiteboardManager.reset_context()
	var res := super.jump_to_widget(widget)
	playtime_changed.emit()
	return res
	#var t := widget.end_time
	#seek(t, false)

func _on_reset() -> void:
	WhiteboardManager.reset_context()
	WhiteboardManager.update_subtitles("")

func jump_to_entity(entity: Entity) -> void:
	var widget := search_widget_by_entity(entity)
	jump_to_widget(widget)

#func jump_to_time(time: float) -> void:
	#pass

func _compute_start_time() -> float:
	return 1.0

func _compute_end_time() -> float:
	return 1.0

func play(speed: float = 1.0) -> void:
	if is_finished():
		#reset()
		seek(0, false)
	super.play(speed) 

func seek(time: float, playing: bool = false) -> void:
	WhiteboardManager.reset_context()
	super.seek(time, playing)
