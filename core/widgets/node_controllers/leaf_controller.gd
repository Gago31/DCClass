class_name LeafController
extends NodeController

var _duration_leaf: float = 0.0 # Duration of the leaf. That is the duration of the widget.
var leaf_value: Widget # The widget value of the leaf. It is the instance of the widget that is being played.


#duration: The duration of the current playing audio.
#total_real_time: The total time between the previous audio and the next audio, without including the audios duration.


# Setup the leaf controller with the instance of the ClassLeaf.
func _setup(instance: ClassLeaf):
	_class_node = instance
	_duration_leaf = instance.entity.duration


# Get the duration of the leaf.
func compute_duration() -> float:
	if is_zero_approx(_duration_leaf):
		_duration_leaf = _compute_duration()
	return _duration_leaf

# Default duration computation.
func _compute_duration() -> float:
	return 0.0

# Play the leaf widget.
#func play_widget(__duration: float, __total_real_time: float):
	## With is_instance_valid we check if the leaf_value is null or if it has been freed. And we also check if the parent is valid.
	#if !is_instance_valid(leaf_value) or !is_instance_valid(leaf_value.get_parent()):
		#if !is_instance_valid(leaf_value):
			## In this case we have to rebuild the leaf_value(widget).
			#load_data(_class_node)
		#
		## We have to reparent the leaf_value to the correct parent, because it could have been changed the visual_slide or audio_widgets.
		#if is_instance_valid(leaf_value.get_parent()):
			#if is_audio():
				#if leaf_value.get_parent() != audio_widgets:
					#leaf_value.reparent(audio_widgets)
		#
			#elif leaf_value.get_parent() != NodeController.get_current_layer():
					#leaf_value.reparent(NodeController.get_current_layer())
#
		## We add to the correct parent (visual or audio).
		#else:
			#if is_audio():
				#audio_widgets.add_child(leaf_value)
			#else:
				#NodeController.get_current_layer().add_child(leaf_value)
	#
	##var sigs: Array[Signal] = [leaf_value.widget_finished, _bus_core.stop_widget]
	##var state = SignalsCore.await_any_once(sigs)
	#
	##leaf_value.play(__duration, __total_real_time, _duration_leaf)
	#
	##if !state._done:
		##await state.completed
		##if state._signal_source == _bus_core.stop_widget:
			##if is_instance_valid(leaf_value):
				##leaf_value.stop()
			##return 1
##
	##return state._signal_value


## We play the leaf in euler order to keep the playing order.
#func play_tree(__duration: float, __total_real_time: float, last_child: NodeController = null) -> void:
	#if __duration == 0.0 or is_audio() or __total_real_time == 0.0: # Case when we didnt have calculated the duration yet or we are on audio leaf.
		#var _duration_calculated = compute_duration_play(self, __duration, __total_real_time)
		#__duration = _duration_calculated[0]
		#__total_real_time = _duration_calculated[1]
	#
	#var state = await play_widget(__duration, __total_real_time)
	#if state == 1 or state == 2:
		#return
	#
	#var parent = _class_node.get_parent_controller()
	#if is_instance_valid(parent):
		#parent.play_tree(__duration, __total_real_time, self)


# Play the leaf widget.
# This is useful to play the current leaf when to current node is a pause. So we omit that pause.
#func play_seekwidget(__duration: float, __total_real_time: float):
	## With is_instance_valid we check if the leaf_value is null or if it has been freed. And we also check if the parent is valid.
	#if !is_instance_valid(leaf_value) or !is_instance_valid(leaf_value.get_parent()):
		#if !is_instance_valid(leaf_value):
			## In this case we have to rebuild the leaf_value(widget).
			#load_data(_class_node)
		#
		## We have to reparent the leaf_value to the correct parent, because it could have been changed the visual_slide or audio_widgets.
		#if is_instance_valid(leaf_value.get_parent()):
			#if is_audio():
				#if leaf_value.get_parent() != audio_widgets:
					#leaf_value.reparent(audio_widgets)
		#
			#elif leaf_value.get_parent() != NodeController.get_current_layer():
					#leaf_value.reparent(NodeController.get_current_layer())
#
		## We add to the correct parent (visual or audio).
		#else:
			#if is_audio():
				#audio_widgets.add_child(leaf_value)
			#else:
				#NodeController.get_current_layer().add_child(leaf_value)
	#
	##var sigs: Array[Signal] = [leaf_value.widget_finished, _bus_core.stop_widget]
	##var state = SignalsCore.await_any_once(sigs)
	#
	#leaf_value.play_seek(__duration, __total_real_time, _duration_leaf)
	#
	##if !state._done:
		##await state.completed
		##if state._signal_source == _bus_core.stop_widget:
			##if is_instance_valid(leaf_value):
				##leaf_value.stop()
			##return 1
##
	##return state._signal_value

# We play from the seeked point to keep the playing order.
# This is useful to play the current leaf when to current node is a pause. So we omit that pause.
#func play_seek(last_child: NodeController = null) -> void:
	#var __duration = 0.0
	#var __total_real_time = 0.0
	#var _duration_calculated = compute_duration_play(self, __duration, __total_real_time)
	#__duration = _duration_calculated[0]
	#__total_real_time = _duration_calculated[1]
	#
	#if leaf_value == null:
		#load_data(_class_node)
		#var parent = leaf_value.get_parent()
		#if parent != null:
			#if is_audio():
				#if leaf_value.get_parent() != audio_widgets:
					#leaf_value.reparent(audio_widgets)
		#
			#elif leaf_value.get_parent() != NodeController.get_current_layer():
					#leaf_value.reparent(NodeController.get_current_layer())
#
		#else:
			#if is_audio():
				#audio_widgets.add_child(leaf_value)
			#else:
				#NodeController.get_current_layer().add_child(leaf_value)
	#
	#leaf_value.reset()
	#
	#if not is_audio():
		#var last_audio = get_previous_audio()
		#if last_audio == null:
			#leaf_value.skip_to_end()
			##_bus_core.pause_playback_widget.emit()
			#return
		#var next_leaf_paudio = last_audio.get_next_leaf(last_audio)
		#var prev_leaf = get_previous_leaf(self)
		#if prev_leaf.is_audio():
			#last_audio._seek_and_play(0.0)
		#else:
			#var time_seek = next_leaf_paudio.compute_total_duration_between(prev_leaf)
			#last_audio._seek_and_play(time_seek * (__duration / __total_real_time))
	#
	#var state = await play_seekwidget(__duration, __total_real_time)
	#if state == 1:
		#return
	#
	#var parent = _class_node.get_parent_controller()
	#if parent != null:
		#parent.play_tree(__duration, __total_real_time, self)

# Check if the leaf is an audio widget.
func is_audio() -> bool:
	if _class_node.entity is AudioEntity:
		return true
	return false


# Seek and play the widget from a specific time.
func _seek_and_play(seek_time: float) -> void:
	leaf_value.seek_and_play(seek_time)


# Skip to the end of the widget. It means playing instantly the widget.
#func skip_to_end() -> void:
	#if !is_instance_valid(leaf_value):
		#load_data(_class_node)
		#
	#var parent = leaf_value.get_parent()
	#if is_instance_valid(parent):
		#if is_audio():
			#if leaf_value.get_parent() != audio_widgets:
				#leaf_value.reparent(audio_widgets)
	#
		#elif leaf_value.get_parent() != NodeController.get_current_layer():
			#leaf_value.reparent(NodeController.get_current_layer())
	#
	#else:
		#if is_audio():
			#audio_widgets.add_child(leaf_value)
		#else:
			#NodeController.get_current_layer().add_child(leaf_value)
	#
	#
	#var sigs: Array[Signal] = [leaf_value.widget_finished]
	#var state = SignalsCore.await_any_once(sigs)
	#leaf_value.skip_to_end()
	#
	#if !state._done:
		#await state.completed
#
#func clear_before_play() -> void:
	#remove_from_group(&"skipped_before_play")
	#if leaf_value != null and is_instance_valid(leaf_value):
		#leaf_value.clear()

# Seek to the given node. Skiping to end all the nodes between node_seek and last_child.
func seek(node_seek: NodeController, last_child: NodeController = null) -> void:
	var current: NodeController = last_child
	var current_node = [current, null]
	while current != null:
		current.skip_to_end()
		if current == node_seek:
			return
		current_node = current.get_next(current_node)
		current = current_node[0]


# Load the data of the leaf. It instantiates the widget and sets the class node.
#func load_data(leaf: ClassLeaf) -> void:
	#var entity_node: Widget = _instantiate_entity()
	#if is_instance_valid(entity_node):
		#leaf_value = entity_node
		
# Instantiate the entity using the data of the class node.
#func _instantiate_entity() -> Widget:
	#var entity: Entity = _class_node.entity
	#if !_has_widget(entity):
		#push_error("Error instantiating entity: " + entity.get_class_name() + ", widget not found")
		#return null
	#var widget: Widget = _get_widget(entity)
	#widget.entity = entity
	#widget.class_node = _class_node
	#widget.init(_class_node.get_properties())
	#return widget

# Check if the entity has a widget associated with it.
#func _has_widget(entity: Entity) -> bool:
	#var _class: String = entity.get_class_name().replace("Entity", "Widget")
	#return CustomClassDB.class_exists(_class)

# Get the widget associated with the entity.
#func _get_widget(entity: Entity) -> Widget:
	#var _class: String = entity.get_class_name().replace("Entity", "Widget")
	#return CustomClassDB.instantiate(_class)


#region Tree Navigation

# Return the next node
func get_next(__current_node: Array, compute_layer:= false) -> Array:
	var current_node = __current_node[0]

	var parent = current_node._class_node.get_parent_controller()
	if parent != null:
		return [parent, current_node]
	return [null, null]

# Return the previous node
func get_previous(__current_node: Array) -> Array:
	var current_node = __current_node[0]

	var parent = current_node._class_node.get_parent_controller()
	if parent != null:
		return [parent, current_node]
	return [null, null]
	

# Return the next leaf node
func get_next_leaf(last_child: NodeController) -> LeafController:
	var parent = _class_node.get_parent_controller()
	if parent != null:
		return parent.get_next_leaf(self)
	return null

# Return the previous leaf node
func get_previous_leaf(last_child: NodeController) -> LeafController:
	var parent = _class_node.get_parent_controller()
	if parent != null:
		return parent.get_previous_leaf(self)
	return null

#endregion


#region Playing Tree Utilities

# Return the last clear leaf node previous to the current node
func get_last_clear() -> LeafController:
	if _class_node.entity is ClearEntity:
		return self
	var prev = get_previous_leaf(self)
	while prev != null:
		if prev._class_node.entity is ClearEntity:
			break
		prev = prev.get_previous_leaf(prev)
	return prev


# Return the next audio leaf node
func get_next_audio() -> LeafController:
	var leaf = get_next_leaf(self)
	while leaf != null:
		if leaf.has_method("is_audio") and leaf.is_audio():
			break
		leaf = leaf.get_next_leaf(leaf)
	return leaf


# Return the previous audio leaf node
func get_previous_audio(current_node: NodeController = self) -> LeafController:
	var leaf = get_previous_leaf(self)
	while leaf != null:
		if leaf.has_method("is_audio") and leaf.is_audio():
			break
		leaf = leaf.get_previous_leaf(leaf)
	return leaf


# Return the total duration between start_leaf and end_leaf
# Start_leaf is the current leaf node (self)
func compute_total_duration_between(end_leaf: LeafController) -> float:
	var total: float = 0.0
	var current: LeafController = self
	while current != null:
		total += current.compute_duration()
		if current == end_leaf:
			break
		current = current.get_next_leaf(current)
	return total

# Return the duration and total_real_time by giving the current node.
func compute_duration_play(current_node: NodeController, _duration: float, _total_real_time: float) -> Array[float]:
	var _previous_audio
	if current_node.has_method("is_audio") and current_node.is_audio():
		_previous_audio = current_node
		_duration = current_node.compute_duration()
	else:
		_previous_audio = get_previous_audio()
		if _previous_audio == null:
			return [0,0]
		_duration = _previous_audio.compute_duration()
	
	var _next_leaf_paudio = _previous_audio.get_next_leaf(_previous_audio)
	
	var _next_audio = get_next_audio()
	
	
	if _next_audio == null:
		if _next_leaf_paudio != null:
			_total_real_time = _next_leaf_paudio.compute_total_duration_between(null)
	else:
		var _prev_leaf_naudio = _next_audio.get_previous_leaf(_next_audio)
		_total_real_time = _next_leaf_paudio.compute_total_duration_between(_prev_leaf_naudio)
	
	return [_duration, _total_real_time]

#endregion
