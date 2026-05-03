class_name SeekTimestampPostprocessor
extends TreePostprocessor

var current_time: float = 0.0
var max_time: float = 0.0


func reset() -> void:
	current_time = 0.0
	max_time = 0.0

func is_widget_valid(widget: Widget) -> bool:
	if widget.get_play_mode() == Widget.PlayMode.SYNC:
		return false
	return true

func _process_widget(widget: Widget) -> void:
	if widget is ClassGroupWidget:
		_process_group(widget as ClassGroupWidget)
	elif widget is ClassLeafWidget:
		_process_leaf(widget as ClassLeafWidget)
	else:
		_update_times(widget)
	var time_str := "%02f~%02f" % [widget.start_time, widget.end_time]
	if widget is ClassNodeWidget:
		prints((widget as ClassNodeWidget).get_class_node().get_editor_name(), time_str)

func _process_group(group: ClassGroupWidget) -> void:
	var i: int = 0
	while i < group.get_child_count():
		var adv := _find_play_and_advance_widget(group, i)
		if not adv: break
		i = adv.get_index() + 1
		var sync_widgets := _find_sync_widgets(group, i)
		group._calculate_sync_speed(sync_widgets, adv.duration)
		var sync_speed := group._sync_speed
		var t := adv.start_time
		for sync in sync_widgets:
			sync.start_time = t
			t += sync.duration / sync_speed
			sync.end_time = t
			var child := sync.get_child(0) as EntityWidget
			child.start_time = sync.start_time
			child.end_time = sync.end_time
	if group.get_child_count() == 0:
		group.start_time = 0.0
		group.end_time = 0.0
		return
	var first_child := group.get_child(0) as Widget
	var last_child := group.get_child(-1) as Widget
	group.start_time = first_child.start_time
	group.end_time = last_child.end_time

func _process_leaf(widget: ClassLeafWidget) -> void:
	var child := widget.get_child(0) as EntityWidget
	widget.start_time = child.start_time
	widget.end_time = child.end_time

func _update_times(widget: Widget) -> void:
	current_time = max_time
	widget.start_time = current_time
	max_time = current_time + widget.duration
	widget.end_time = max_time

func _find_play_and_advance_widget(parent: ClassGroupWidget, from: int) -> Widget:
	for i in range(from, parent.get_child_count()):
		var child := parent.get_child(i) as Widget
		if child.get_play_mode() == Widget.PlayMode.PLAY_AND_ADVANCE:
			return child
	return null

func _find_sync_widgets(parent: ClassGroupWidget, from: int) -> Array[ClassNodeWidget]:
	var sync_widgets: Array[ClassNodeWidget] = []
	for i in range(from, parent.get_child_count()):
		var child := parent.get_child(i) as Widget
		var play_mode := child.get_play_mode()
		if play_mode in [Widget.PlayMode.SYNC, Widget.PlayMode.INSTANT]:
			sync_widgets.append(child)
		elif play_mode in [Widget.PlayMode.PLAY_AND_ADVANCE, Widget.PlayMode.PLAY_AND_WAIT]:
			break
	return sync_widgets
