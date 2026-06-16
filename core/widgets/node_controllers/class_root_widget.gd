class_name ClassRootWidget
extends ClassGroupWidget

signal playtime_changed

func jump_to_widget(widget: Widget) -> bool:
	#WhiteboardManager.reset_context()
	reset()
	#playtime_changed.emit()
	#print("reset")
	#return true
	var res := super.jump_to_widget(widget)
	playtime_changed.emit()
	return res
	#var t := widget.end_time
	#seek(t, false)

func _on_reset() -> void:
	WhiteboardManager.reset_context()
	WhiteboardManager.update_subtitles("")
	super._on_reset()

func _on_finished_playing() -> void:
	super._on_finished_playing()
	var final_node: ClassNodeWidget = self
	while not final_node.is_leaf():
		if final_node.get_child_count() == 0:
			break
		final_node = final_node.get_child(-1) as ClassNodeWidget
	jump_to_widget(final_node)
	final_node.get_class_node().select_own_item()

func jump_to_entity(entity: Entity) -> void:
	var widget := search_widget_by_entity(entity)
	jump_to_widget(widget)

#func jump_to_time(time: float) -> void:
	#pass

func get_current_entity_widget() -> EntityWidget:
	return _get_current_entity_widget()

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
