class_name ClassSlideWidget
extends ClassGroupWidget

func _jump_to_node(node: ClassNode) -> bool:
	if node == get_class_node():
		reset()
		return true
	for child in get_children() as Array[ClassNodeWidget]:
		var stop_search := child._jump_to_node(node)
		if stop_search: return true
	hide()
	return false

#func _on_reset() -> void:
	#show()

func _on_finished_playing() -> void:
	hide()
	super._on_finished_playing()

func _on_skip() -> void:
	hide()
