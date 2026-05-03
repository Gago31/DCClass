class_name ClassGroupWidget
extends ClassNodeWidget


signal child_added

#var _reference_time: float = 0.0
var _sync_speed: float = 0.0
var _current_node: ClassNodeWidget


func setup() -> void:
	var node := get_class_node()
	node.child_added.connect(_on_child_added)
	node.children_cleared.connect(_on_children_cleared)
	
	for class_node in get_class_node().children:
		_build_child(class_node)

func _build_child(child: ClassNode, index: int = -1) -> ClassNodeWidget:
	var node := child.get_widget().instantiate() as ClassNodeWidget
	node.set_class_node(child)
	add_child(node)
	if index >= 0:
		move_child(node, index)
	node.setup()
	return node

func _on_started_playing() -> void:
	#show()
	WhiteboardManager.push_context()
	_play_next()

func _on_finished_playing() -> void:
	if is_seeking(): return
	WhiteboardManager.pop_context()

func _on_paused() -> void:
	if not _current_node: return
	for child in get_children() as Array[ClassNodeWidget]:
		if child.is_playing():
			child.pause()

func _on_unpaused() -> void:
	_unpause()

func _on_reset() -> void:
	#hide()
	unclear()
	_disconnect_current()
	for child in get_children() as Array[ClassNodeWidget]:
		child.reset()

func seek(time: float, playing: bool = false) -> void:
	unclear()
	super.seek(time, playing)
	_disconnect_current()
	_current_node = null
	WhiteboardManager.push_context()
	for child in get_children() as Array[ClassNodeWidget]:
		child.seek(time, playing)
	for child in get_children() as Array[ClassNodeWidget]:
		if child.is_playing() or child.is_paused():
			_current_node = child
	if _current_node:
		_connect_current()
	#show()

func _on_skip() -> void:
	show()
	_set_play_state(PlayState.FINISHED)
	_current_node = null
	for child in get_children() as Array[ClassNodeWidget]:
		child.jump_to_end()

# Meant to be used by [ClassRoot]'s `jump_to_node()`
func _jump_to_node(node: ClassNode) -> bool:
	if node == get_class_node():
		reset()
		return true
	for child in get_children() as Array[ClassNodeWidget]:
		var stop_search := child._jump_to_node(node)
		if stop_search: return true
	return false

#func _jump_to_time(time: float) -> bool:
	#return false

func _compute_start_time() -> float:
	return 1.0

func _compute_end_time() -> float:
	return 1.0

func _calculate_duration() -> float:
	var total_time: float = 0.0
	for child in get_children() as Array[ClassNodeWidget]:
		# SYNC nodes are skipped because they finish at the same
		# time as the previous PLAY_AND_ADVANCE
		if child.get_play_mode() in [PlayMode.PLAY_AND_ADVANCE, PlayMode.PLAY_AND_WAIT]:
			total_time += child.get_duration()
	return total_time

func get_class_node() -> ClassGroup:
	return _node as ClassGroup

func get_play_mode() -> PlayMode:
	return PlayMode.PLAY_AND_WAIT

# This collects all the SYNC nodes after the current PLAY_AND_ADVANCE node
# and before the next PLAY_AND_* node. 
func _get_sync_nodes_after(child: ClassNodeWidget) -> Array[ClassNodeWidget]:
	var sync_nodes: Array[ClassNodeWidget] = []
	var index_i := child.get_index() + 1
	
	for i in range(index_i, get_child_count()):
		var node := get_child(i) as ClassNodeWidget
		var node_play_mode := node.get_play_mode()
		if node_play_mode == PlayMode.SYNC:
			sync_nodes.append(node)
		elif node_play_mode in [PlayMode.PLAY_AND_ADVANCE, PlayMode.PLAY_AND_WAIT]:
			break
	return sync_nodes

# This determines how much we need to accelerate the playback speed of
# the following nodes to match the duration of the reference node
func _calculate_sync_speed(nodes: Array[ClassNodeWidget], reference_time: float) -> void:
	if reference_time <= 0.0:
		_sync_speed = 1.0
		return
	var total_duration := 0.0
	for node in nodes:
		total_duration += node.duration
	if total_duration == 0.0:
		_sync_speed = 1.0
		return
	_sync_speed = total_duration / reference_time

func _unpause(speed: float = 1.0) -> void:
	#_play_current(speed)
	for child in get_children() as Array[ClassNodeWidget]:
		if child.is_paused():
			child.play(speed)
	if _current_node.is_finished():
		_play_next()
	#_current_node.play(speed)

func _connect_current() -> void:
	if not _current_node: return
	if _current_node.finished_playing.is_connected(_play_next): return
	_current_node.finished_playing.connect(_play_next, CONNECT_ONE_SHOT)

func _disconnect_current() -> void:
	if not _current_node: return
	if _current_node.finished_playing.is_connected(_play_next):
		_current_node.finished_playing.disconnect(_play_next)
	_current_node = null

func _play_current() -> void:
	#_play_state = PlayState.PLAYING
	#started_playing.emit()
	if is_paused(): return
	match _current_node.get_play_mode():
		PlayMode.INSTANT:
			_connect_current()
			_current_node.play(_play_speed)
		PlayMode.SYNC:
			_connect_current()
			_current_node.play(_play_speed)
			#_current_node.play(_play_speed * _sync_speed)
		PlayMode.PLAY_AND_ADVANCE:
			var reference_time = _current_node.duration
			var sync_nodes := _get_sync_nodes_after(_current_node)
			if sync_nodes.is_empty():
				_connect_current()
				_current_node.play(_play_speed)
			else:
				_calculate_sync_speed(sync_nodes, reference_time)
				_current_node.play(_play_speed)
				_play_next()
		PlayMode.PLAY_AND_WAIT:
			if not _current_node.finished_playing.is_connected(_play_next):
				_connect_current()
			_current_node.play(_play_speed)

func _play_next() -> void:
	var next_index := 0
	if _current_node:
		next_index = _current_node.get_index() + 1
	if next_index >= get_child_count():
		finish_playing()
		return
	_current_node = get_child(next_index)
	_play_current()

func _on_child_finished_playing() -> void:
	_play_next()

func _on_child_added(child: ClassNode, index: int) -> void:
	var node := _build_child(child, index)
	node.jump_to_end()
	child_added.emit()

func _on_children_cleared() -> void:
	for child in get_children():
		child.queue_free()

func search_widget_by_entity(value: Entity) -> Widget:
	for child in get_children() as Array[ClassNodeWidget]:
		var child_res := child.search_widget_by_entity(value)
		if child_res:
			return child_res
	return null

func search_widget_by_class_node(value: ClassNode) -> Widget:
	if get_class_node() == value:
		return self
	for child in get_children() as Array[ClassNodeWidget]:
		var child_res := child.search_widget_by_class_node(value)
		if child_res:
			return child_res
	return null

func is_leaf() -> bool:
	return false

func clear_until(widget: Widget) -> bool:
	var index: int = -1
	for child in get_children() as Array[ClassNodeWidget]:
		var res := child.clear_until(widget)
		if child.is_leaf() and res:
			index = child.get_index()
			break
		elif res:
			return true
	if index == -1:
		return false
	for i in index:
		var child := get_child(i) as ClassNodeWidget
		child.hide()
	return true

func unclear() -> void:
	show()
	for child in get_children() as Array[ClassNodeWidget]:
		child.unclear()

func jump_to_widget(target_widget: Widget) -> bool:
	print("Jump to widget")
	reset()
	if target_widget == self:
		return true
	for child in get_children() as Array[ClassNodeWidget]:
		var stop_search := child.jump_to_widget(target_widget)
		if not stop_search: continue
		if child.is_leaf():
			play_time = child.end_time - start_time
		else:
			play_time = child.start_time + child.play_time - start_time
		_current_node = child
		_connect_current()
		pause()
		#_set_play_state(PlayState.PAUSED)
		return true
	play_time = duration
	_set_play_state(PlayState.FINISHED)
	return false
