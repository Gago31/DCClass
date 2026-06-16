class_name EditorWhiteboardInput
extends WhiteboardInputDesktop

#const WARP_OFFSET := -10
const SQUARED_THRESHOLD := 4.0

#var _dragging: bool = false
#var _warped: bool = false

# pen
var _pen_enabled: bool = false
var _pressed: bool = false
var _line: Line2D
var _last_point: Vector2 = Vector2.INF
var _drag_start_pos: Vector2
var _scale_origin: Vector2
var _delays: Array[float] = []
var _last_time: float = 0.0
var _selected_widgets: Array[VisualEntityWidget] = []
var _multi_select_active := false
var line_buffer: Array[BufferedLine] = []
var undoing := false

#@onready var _viewport: SubViewport = %SubViewport
#@onready var subtitles: RichTextLabel = %Subtitles
@onready var _selection_box: SelectionBox = %SelectionBox
#@onready var camera: ClassCameraEditor = %Camera2D

func _ready() -> void:
	_selection_box.widgets_selected.connect(_on_widgets_selected)
	await get_tree().process_frame
	WhiteboardManager.get_root_widget().updated.connect(_clear_line_buffer)
	WhiteboardManager.get_root_widget().playtime_changed.connect(_clear_line_buffer)
	WhiteboardManager.input_controller = self

func _gui_input(event):
	if event is InputEventMouse:
		match EditorManager.pen_mode:
			EditorManager.PenMode.DISABLED:
				_handle_screen_dragging(event)
			EditorManager.PenMode.SELECT:
				_handle_widget_selection(event)
			EditorManager.PenMode.DRAW:
				_handle_drawing(event)
			EditorManager.PenMode.DRAG:
				_handle_node_dragging(event)
			EditorManager.PenMode.RESIZE:
				_handle_node_resize(event)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("undo"):
		undoing = true
		_undo_line()
		undoing = false
	elif event.is_action_pressed("redo"):
		pass

func _on_pen_toggled(active: bool) -> void:
	_pen_enabled = active
	_last_time = Time.get_ticks_msec() / 1000.0

func _handle_drawing(event: InputEvent) -> void:
	if not event is InputEventMouseMotion: return
	if not is_instance_valid(_viewport): return
	var pos: Vector2 = _viewport.get_camera_2d().get_global_mouse_position()
	##############################################
	#var now := Time.get_ticks_msec() * 0.001
	#
	#if event is InputEventMouseButton:
		#var button_event := event as InputEventMouseButton
		#if button_event.button_index == MOUSE_BUTTON_LEFT:
			#if button_event.is_pressed() and not _pressed:
				#_pressed = true
				#WhiteboardManager.notify_started_drawing()
				#_line = _new_line()
				#_viewport.add_child(_line)
				#_line.add_point(pos)
				#_last_point = pos
				#
				#_delays.clear()
				##var delta_time := now - _last_time
				##if delta_time > 10:
					##delta_time = 10
				#_delays.append(0)
				#_last_time = now
			#elif _pressed:
				#_pressed = false
				#_line.add_point(pos)
				#var delta_time := now - _last_time
				#if delta_time > 10:
					#delta_time = 10
				#_delays.append(delta_time)
#
				#var entity := LineEntity.new()
				#entity.points = _line.points
#
				#var _position_origin: Vector2 = _line.points[0]
				#for i in range(entity.points.size()):
					#entity.points[i] -= _position_origin
				#
				#entity.delays = _delays.duplicate() as Array[float]
				#entity.duration = entity.compute_duration()
				#entity.transform.origin = _position_origin
				##print("Added lines with delays ", _delays)
				#
				#EditorManager.add_entity(entity)
				#
				#var parent := _line.get_parent()
				#
				#parent.remove_child(_line)
				#_line.queue_free()
				#_line = null
		#elif button_event.button_index == MOUSE_BUTTON_MIDDLE:
			#_handle_screen_dragging(event)
	#elif event is InputEventMouseMotion:
		#var motion_event := event as InputEventMouseMotion
		#if motion_event.button_mask & MOUSE_BUTTON_LEFT:
			#if not _pressed: return
			#_line.set_point_position(_line.get_point_count() - 1, pos)
#
			#if _last_point.distance_squared_to(pos) > SQUARED_THRESHOLD:
				#_line.add_point(pos)
				#var delta_time := now - _last_time
				#if delta_time > 5:
					#delta_time = 5
				#_delays.append(delta_time)
				#_last_time = now
				#_last_point = pos
			#WhiteboardManager.notify_stopped_drawing()
		#elif motion_event.button_mask & MOUSE_BUTTON_MIDDLE:
			#_handle_screen_dragging(event)
	#return
	########################################################
	
	if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		var now := Time.get_ticks_msec() / 1000.0

		if not _pressed:
			_pressed = true
			WhiteboardManager.notify_started_drawing()
			_line = _new_line()
			_viewport.add_child(_line)
			_line.add_point(pos)
			_last_point = pos
			
			_delays.clear()
			var delta_time := now - _last_time
			if delta_time > 10:
				delta_time = 10
			_delays.append(delta_time)
			_last_time = now
		else:
			_line.set_point_position(_line.get_point_count() - 1, pos)

			if _last_point.distance_squared_to(pos) > SQUARED_THRESHOLD:
				_line.add_point(pos)
				var delta_time := now - _last_time
				if delta_time > 5:
					delta_time = 5
				_delays.append(delta_time)
				_last_time = now
				_last_point = pos
			
	elif _pressed:
		_line.add_point(pos)
		_pressed = false

		var now := Time.get_ticks_msec() / 1000.0
		var delta_time := now - _last_time
		if delta_time > 10:
			delta_time = 10
		_delays.append(delta_time)

		var entity := LineEntity.new()
		entity.points = _line.points

		var _position_origin: Vector2 = _line.points[0]
		for i in range(entity.points.size()):
			entity.points[i] -= _position_origin
		
		entity.delays = _delays.duplicate() as Array[float]
		entity.duration = entity.compute_duration()
		entity.transform.origin = _position_origin
		#print("Added lines with delays ", _delays)
		
		EditorManager.add_entity(entity, true, false)
		WhiteboardManager.notify_stopped_drawing()
		#var parent := _line.get_parent()
		
		_buffer_line(_line, entity)
		_line = null
		#var buffered_line := BufferedLine.new()
		#buffered_line.line = _line
		#buffered_line.entity = entity
		#line_buffer.append(buffered_line)
		#parent.remove_child(_line)
		#_line.queue_free()
		#_line = null

func _buffer_line(line: Line2D, entity: LineEntity) -> void:
	var buffered_line := BufferedLine.new()
	buffered_line.line = line
	buffered_line.entity = entity
	line_buffer.append(buffered_line)

func _undo_line() -> void:
	if line_buffer.is_empty(): return
	var last_line := line_buffer[-1]
	last_line.line.free()
	EditorManager.delete_entity(last_line.entity)
	line_buffer.pop_back()

func _clear_line_buffer() -> void:
	if undoing: return
	for buffered_line in line_buffer:
		buffered_line.line.queue_free()
	line_buffer.clear()

func _handle_widget_selection(event: InputEvent) -> void:
	if event.is_action_pressed(&"multi_select"):
		_multi_select_active = true
	elif event.is_action_released(&"multi_select"):
		_multi_select_active = false
		
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		if button_event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = button_event.is_pressed()
			if button_event.is_pressed():
				var current_pos := _viewport.get_camera_2d().get_global_mouse_position()
				_selection_box.begin_selection(current_pos)
			else:
				_selection_box.confirm_selection()
		elif button_event.button_index == MOUSE_BUTTON_RIGHT:
			if button_event.is_pressed():
				_selection_box.cancel_selection()
		elif button_event.button_index == MOUSE_BUTTON_MIDDLE:
			_handle_screen_dragging(event)
	elif event is InputEventMouseMotion:
		var motion_event := event as InputEventMouseMotion
		if motion_event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			if _dragging:
				var current_pos := _viewport.get_camera_2d().get_global_mouse_position()
				_selection_box.update_selection(current_pos)
		elif motion_event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			_handle_screen_dragging(event)

#region properties handling


func _get_drag_vector(current_drag_pos: Vector2) -> Vector2:
	var snap := Input.is_action_pressed("multi_select")
	var displacement := current_drag_pos - _drag_start_pos
	if snap:
		displacement = displacement.snapped(Vector2(64, 64))
	return displacement

func _handle_node_dragging(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		if button_event.button_index != MOUSE_BUTTON_LEFT: return
		if button_event.pressed:
			_drag_start_pos = _viewport.get_camera_2d().get_global_mouse_position()
			_dragging = true
		elif _dragging:
			_dragging = false
			var drag_end_pos := _viewport.get_camera_2d().get_global_mouse_position()
			var displacement := _get_drag_vector(drag_end_pos)
			for widget in _selected_widgets:
				if not widget.is_visible_in_tree(): continue
				widget.restore_transform()
				widget.move(displacement)
			_drag_start_pos = Vector2.ZERO
	elif event is InputEventMouseMotion and _dragging:
		var current_drag_pos := _viewport.get_camera_2d().get_global_mouse_position()
		for widget in _selected_widgets:
			var displacement := _get_drag_vector(current_drag_pos)
			widget.temp_drag(displacement)

func _set_scale_origin() -> void:
	var total := Vector2.ZERO
	for widget in _selected_widgets:
		total += widget.global_position
	_scale_origin = total / _selected_widgets.size()

func _get_scale_factor(current_drag_pos: Vector2) -> float:
	var dist := current_drag_pos.distance_to(_drag_start_pos)
	var origin_vector := _drag_start_pos - _scale_origin
	var mouse_vector := current_drag_pos - _drag_start_pos
	var dot := origin_vector.dot(mouse_vector)
	var scale_factor := 1.0 + dist / origin_vector.length() * signf(dot)
	if Input.is_action_pressed("multi_select"):
		scale_factor = snappedf(scale_factor, 0.1)
	return scale_factor

func _handle_node_resize(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		if button_event.button_index != MOUSE_BUTTON_LEFT: return
		if button_event.pressed:
			_drag_start_pos = _viewport.get_camera_2d().get_global_mouse_position()
			_set_scale_origin()
			_dragging = true
		elif _dragging:
			_dragging = false
			var drag_end_pos := _viewport.get_camera_2d().get_global_mouse_position()
			var scale_factor := _get_scale_factor(drag_end_pos)
			for widget in _selected_widgets:
				if not widget.is_visible_in_tree(): continue
				widget.restore_transform()
				widget.scale_uniform(scale_factor)
			_drag_start_pos = Vector2.ZERO
	elif event is InputEventMouseMotion and _dragging:
		var current_drag_pos := _viewport.get_camera_2d().get_global_mouse_position()
		var scale_factor := _get_scale_factor(current_drag_pos)
		for widget in _selected_widgets:
			#widget.restore_position()
			widget.temp_scale(scale_factor)

#endregion


func _new_line() -> Line2D:
	var l := Line2D.new()
	l.width = WhiteboardManager.get_pen_thickness()
	l.default_color = WhiteboardManager.get_pen_color()
	l.begin_cap_mode = Line2D.LINE_CAP_ROUND
	l.end_cap_mode = Line2D.LINE_CAP_ROUND
	l.joint_mode = Line2D.LINE_JOINT_ROUND
	l.antialiased = true
	return l

#func _on_subtitles_updated(text: String) -> void:
	#subtitles.parse_bbcode(text)

func _clear_widget_selection() -> void:
	for widget in _selected_widgets:
		widget.deselect()
	_selected_widgets.clear()

func set_selected_widgets(widgets: Array[VisualEntityWidget]) -> void:
	_selected_widgets = widgets

func _on_widgets_selected(widgets: Array[VisualEntityWidget], multi_select: bool) -> void:
	if widgets.size() == 1 and widgets[0] in _selected_widgets \
		and (_selected_widgets.size() == 1 or multi_select):
			widgets[0].deselect()
			_selected_widgets.erase(widgets[0])
			return
	if not multi_select:
		_clear_widget_selection()
	for widget in widgets:
		if not widget.is_visible_in_tree(): continue
		if widget in _selected_widgets: continue
		widget.select()
		_selected_widgets.append(widget)

class BufferedLine:
	var line: Line2D
	var entity: LineEntity
