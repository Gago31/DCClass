class_name GroupController
extends NodeController


var _childrens: Array[ClassNode] = []

# Returns the index of the controller in _childrens[ClassNode]
func _index_of(current_node: NodeController) -> int:
	if current_node == null:
		return -1
	return _childrens.find(current_node._class_node)


# Setup the controller with the given ClassGroup instance.
func _setup(instance: ClassGroup):
	_class_node = instance
	_childrens = instance._childrens


# Play the group in euler-order
func play_tree(__duration: float = 0.0, __total_real_time: float = 0.0, last_child: NodeController = null) -> void:
	var index = _index_of(last_child)
	
	# Check if we are in a border case
	## This case is when the group has no children or the last child is the last child of the group.
	if _childrens.size() == 0 or index + 1 == _childrens.size():
		var parent = _class_node.get_parent_controller() # We keep the playing to the parent controller

		if parent != null:
			parent.play_tree(__duration, __total_real_time, self)
			return
		
		# We are in the the last node of the tree so we wait for the last audio to finish
		var audio_current_playing = get_tree().get_nodes_in_group("audio_playing")
		#if audio_current_playing.size() > 0:
			#var sigs: Array[Signal] = [audio_current_playing[0].audio.finished, _bus_core.stop_widget]
			#var state = SignalsCore.await_any_once(sigs)
			#if !state._done:
				#await state.completed
				#if state._signal_source == _bus_core.stop_widget:
					#return
		#_bus_core.tree_play_finished.emit()
		return
	
	# Play the next child after the last_child
	var next_child_to_play = _childrens[index + 1]._node_controller
	if next_child_to_play is SlideController:
		NodeController.push_slide_layer()
		
	next_child_to_play.play_tree(__duration, __total_real_time, self)


# We play the group from the seeked point.
# This is useful to play without 
func play_seek(last_child: NodeController = null) -> void:
	var index = _index_of(last_child)

	if _childrens.size() == 0 or index + 1 == _childrens.size():
		var parent = _class_node.get_parent_controller()
		if parent != null:
			parent.play_seek(self)
			return
		#We are the root
		#_bus_core.tree_play_finished.emit()
		return
	
	var next_child_to_play = _childrens[index + 1]._node_controller
	next_child_to_play.play_seek(self)


# Seek to the given node. Skiping to end all the nodes between node_seek and last_child.
func seek(node_seek: NodeController, last_child: NodeController = null) -> void:
	var current: NodeController = last_child
	var current_node = [self, last_child]
	while current != null:
		current.skip_to_end()
		if current == node_seek:
			# hotfix tmp: should remove editor bus dependancy
			#if !is_instance_valid(_bus):
				#return
			#_bus.emit_signal("execute_after_rendering")
			return
		current_node = current.get_next(current_node, true)
		current = current_node[0]
	return

#region Tree Navigation

# Return the next NodeController after __current_node
func get_next(__current_node: Array, compute_layer:= false) -> Array:
	var current_node = __current_node[0]
	var last_child = __current_node[1]
	var index = current_node._index_of(last_child)
		
	if current_node._childrens.size() == 0 or index + 1 == current_node._childrens.size():
		var parent = current_node._class_node.get_parent_controller()
		if parent != null:
			# Pop current layer if is computing (called only on seek)
			if current_node is SlideController and compute_layer:
				NodeController.pop_slide_layer()
				get_tree().call_group(&"widget_cleared", "unclear")
				NodeController.unhide_layers()
			return [parent, current_node]
		return [null, null]
	
	var next_child = current_node._childrens[index + 1]._node_controller
	# Push current layer if is computing (called only on seek)
	if next_child is SlideController and compute_layer:
		NodeController.push_slide_layer()

	return [next_child, null]


# Return the previous LeafController before last_child
func get_previous(__current_node: Array) -> Array:
	var current_node = __current_node[0]
	var last_child = __current_node[1]
	var index = current_node._index_of(last_child)
	
	if index == -1:
		index = current_node._childrens.size()
	
	if current_node._childrens.size() == 0 or index - 1 <= -1:
		var parent = current_node._class_node.get_parent_controller()
		if parent != null:
			return [parent, current_node]
		return [null, null]

	var prev_child = current_node._childrens[index - 1]._node_controller
	return [prev_child, null]


# Return the next LeafController after last_child
func get_next_leaf(last_child: NodeController) -> LeafController:
	var current_node = self
	var next_child = get_next([current_node, last_child])
	while next_child[0] != null:
		if next_child[0] is LeafController:
			return next_child[0]
		next_child = next_child[0].get_next([next_child[0], next_child[1]])
	return null


# Return the previous LeafController before last_child
func get_previous_leaf(last_child: NodeController) -> LeafController:
	var current_node = self
	var prev_child = get_previous([current_node, last_child])
	while prev_child[0] != null:
		if prev_child[0] is LeafController:
			return prev_child[0]
		prev_child = prev_child[0].get_previous([prev_child[0], prev_child[1]])
	return null

func skip_all_children():
	for i in range(_childrens.size()):
		var child = _childrens[i]._node_controller
		child.add_to_group(&"skipped_before_play")
		child.skip_to_end()

#endregion


#region Playing Tree Utilities

# Return the last ClearEntity before the current node
func get_last_clear() -> LeafController:
	var last_children
	if _childrens.is_empty():
		last_children = self
	else:
		last_children = _childrens[0]._node_controller
	
	var prev = get_previous_leaf(last_children)
	while prev != null and not (prev._class_node.entity is ClearEntity):
		prev = prev.get_previous_leaf(prev)
	return prev

# Return the next LeafController that is an audio
func get_next_audio(current_node: NodeController) -> LeafController:
	var leaf = get_next_leaf(current_node)
	while leaf != null and not leaf.is_audio():
		leaf = leaf.get_next_leaf(leaf)
	return leaf


# Return the previous LeafController that is an audio
func get_previous_audio(current_node: NodeController) -> LeafController:
	var leaf = get_previous_leaf(current_node)
	while leaf != null:
		if leaf.has_method("is_audio") and leaf.is_audio():
			break
		leaf = leaf.get_previous_leaf(leaf)
	return leaf

# Return the total duration between start_leaf and end_leaf
func compute_total_duration_between(start_leaf: LeafController, end_leaf: LeafController) -> float:
	var total: float = 0.0
	var current: LeafController = start_leaf
	while current != null:
		total += current.compute_duration()
		if current == end_leaf:
			break
		current = current.get_next_leaf(current)
	return total

# Compute the duration and total real time of the previous audio before the current node and the next audio after the current node.
func _compute_duration_play(current_node: NodeController, _duration: float = 0.0, _total_real_time: float = 0.0) -> Array[float]:
	var _previous_audio
	if current_node.has_method("is_audio") and current_node.is_audio():
		_previous_audio = current_node
		_duration = current_node.compute_duration()
	else:
		_previous_audio = get_previous_audio(current_node)
		_duration = _previous_audio.compute_duration()
	
	var _next_leaf_paudio = _previous_audio.get_next_leaf()
	var _next_audio = get_next_audio(current_node)
	if _next_audio == null:
		_total_real_time = _next_leaf_paudio.compute_total_duration_between(null)
	else:
		var _prev_leaf_naudio = _next_audio.get_previous_leaf(self)
		_total_real_time = _next_leaf_paudio.compute_total_duration_between(_prev_leaf_naudio)
	
	return [_duration, _total_real_time]

# Compute the complete class duration.
# Designed to be only used by the root of the tree.
func _compute_class_duration() -> float:
	var c_audio = get_next_audio(self)
	var duration : float = 0
	while c_audio != null:
		duration += c_audio.compute_duration()
		c_audio = c_audio.get_next_audio()
	return duration

# Compute the current time for the giving node.
# Designed to be only used by the root of the tree.
func _compute_current_time(_current_node : NodeController ) -> float:
	if _current_node is GroupController:
		var next_leaf = _current_node.get_next_leaf(_current_node)
		if next_leaf == null: # Case: There is not other leaf in the class.
			return 0.0
		_current_node = next_leaf

	
	var c_audio = get_next_audio(self)
	var duration : float = 0
	var current_audio
	if _current_node.has_method("is_audio") and _current_node.is_audio():
		current_audio = _current_node
	else:
		current_audio = _current_node.get_previous_audio(_current_node)

	while c_audio != null and c_audio != current_audio:
		duration += c_audio.compute_duration()
		c_audio = c_audio.get_next_audio()


	var __duration = 0.0
	var __total_real_time = 0.0

	var _duration_calculated = _current_node.compute_duration_play(_current_node, __duration, __total_real_time)
	__duration = _duration_calculated[0]
	__total_real_time = _duration_calculated[1]
	if _duration_calculated == [0.0,0.0]:
		return 0.0
	
	if _current_node.has_method("is_audio") and not _current_node.is_audio():
		var last_audio = _current_node.get_previous_audio(_current_node)
		var next_leaf_paudio = last_audio.get_next_leaf(last_audio)
		var prev_leaf = _current_node.get_previous_leaf(self)
			
		if prev_leaf.is_audio():
			pass
		else:
			var time_seek = next_leaf_paudio.compute_total_duration_between(_current_node.get_previous_leaf(_current_node))
			duration += time_seek * (__duration / __total_real_time)
	
	return duration

# Get the current node for the giving a time.
# Designed to be only used by the root of the tree.
func _seek_node_time(_current_time : float) -> NodeController:
	var c_audio = get_next_audio(self)
	if c_audio == null: # Case: There is not audio in the class.
		return self
	var duration : float = 0
	var c_node : LeafController = c_audio
	while true:
		c_node = c_audio
		var c_audio_dur = c_audio.compute_duration()
		if _current_time < duration + c_audio_dur:
			break
		
		c_audio = c_audio.get_next_audio()
		if c_audio == null:
			break
		duration += c_audio_dur
		
		

	var __duration = 0.0
	var __total_real_time = 0.0
	
	
	var _duration_calculated = c_node.compute_duration_play(c_node, __duration, __total_real_time)
	__duration = _duration_calculated[0]
	__total_real_time = _duration_calculated[1]

	var n_node : LeafController = c_node.get_next_leaf(c_node)
	while n_node != null:
		if n_node.has_method("is_audio") and n_node.is_audio():
			break
		else:
			c_node = n_node
			var time_leaf = (__duration / __total_real_time) * c_node.compute_duration()
			if _current_time < duration + time_leaf:
				break
			duration += time_leaf
		n_node = c_node.get_next_leaf(c_node)

	return c_node

#endregion
