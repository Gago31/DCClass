class_name SlideController
extends GroupController

# Play the group in euler-order
func play_tree(__duration: float = 0.0, __total_real_time: float = 0.0, last_child: NodeController = null) -> void:
	var index = _index_of(last_child)
	
	# Check if we are in a border case
	## This case is when the group has no children or the last child is the last child of the group.
	if _childrens.size() == 0 or index + 1 == _childrens.size():
		var parent = _class_node.get_parent_controller() # We keep the playing to the parent controller


		if parent != null:
			# Pop current layer on leaving a slide
			NodeController.pop_slide_layer()
			get_tree().call_group(&"widget_cleared", "unclear")
			NodeController.unhide_layers()
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
