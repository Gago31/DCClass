class_name ClassLeafWidget
extends ClassNodeWidget


var entity: Entity
var widget: EntityWidget


func setup() -> void:
	entity = get_class_node().entity
	var scene := entity.get_widget()
	widget = scene.instantiate() as EntityWidget
	widget.entity = entity
	add_child(widget)
	widget.setup()
	widget.finished_playing.connect(_on_widget_finished)

func _on_started_playing() -> void:
	widget.play(_play_speed)

func _on_unpaused() -> void:
	widget.play()

func _on_paused() -> void:
	widget.pause()

func seek(time: float, playing: bool = false) -> void:
	super.seek(time, playing)
	widget.seek(time, playing)

func _on_reset() -> void:
	show()
	widget.reset()

func _on_skip() -> void:
	widget.jump_to_end()

func _calculate_duration() -> float:
	return widget.get_duration()

func get_play_mode() -> PlayMode:
	return widget.get_play_mode()

func _on_widget_finished() -> void:
	_set_play_state(PlayState.FINISHED)
	finished_playing.emit()

func get_class_node() -> ClassLeaf:
	return _node as ClassLeaf

# Meant to be used by [ClassRoot]'s `jump_to_node()`
func _jump_to_node(node: ClassNode) -> bool:
	if node == get_class_node():
		reset()
		return true
	jump_to_end()
	return false

func _jump_to_time(time: float) -> bool:
	return false

func _compute_start_time() -> float:
	return 0.0

func _compute_end_time() -> float:
	return 0.0

func search_widget_by_entity(value: Entity) -> Widget:
	return widget.search_widget_by_entity(value)

func search_widget_by_class_node(value: ClassNode) -> Widget:
	if get_class_node() == value:
		return self
	return null

func is_leaf() -> bool:
	return true

func clear_until(target_widget: Widget) -> bool:
	return widget == target_widget

func unclear() -> void:
	show()
	widget.show()

func jump_to_widget(target_widget: Widget) -> bool:
	jump_to_end()
	if target_widget == self or widget == target_widget:
		return true
	return false
