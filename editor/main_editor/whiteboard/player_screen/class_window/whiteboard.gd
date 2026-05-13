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

#@onready var _viewport: SubViewport = %SubViewport
#@onready var subtitles: RichTextLabel = %Subtitles
@onready var _selection_box: SelectionBox = %SelectionBox
#@onready var camera: ClassCameraEditor = %Camera2D

func _ready() -> void:
	_selection_box.widgets_selected.connect(_on_widgets_selected)

func _gui_input(event):
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

func _on_pen_toggled(active: bool) -> void:
	_pen_enabled = active
	_last_time = Time.get_ticks_msec() / 1000.0

func _handle_drawing(event: InputEvent) -> void:
	if not event is InputEventMouseMotion: return
	if not is_instance_valid(_viewport): return
	var pos: Vector2 = _viewport.get_camera_2d().get_global_mouse_position()
	
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
			WhiteboardManager.notify_stopped_drawing()
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
		
		entity.delays = _delays.duplicate()
		entity.duration = entity.compute_duration()
		entity.transform.origin = _position_origin
		
		EditorManager.add_entity(entity)
		
		var parent := _line.get_parent()
		
		parent.remove_child(_line)
		_line.queue_free()
		_line = null


#func _handle_screen_dragging(event: InputEvent) -> void:
	##if not (_pen_enabled or _node_drag_enabled):
	##_handle_widget_selection(event)
#
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#get_viewport().set_input_as_handled()
		#_dragging = event.is_pressed()
	#elif event is InputEventMouseMotion and _dragging:
		#get_viewport().set_input_as_handled()
#
		#camera.user_controlled = true
		#camera.position -= event.relative
#
		#var mouse_pos: Vector2 = event.global_position
		#var view := get_global_rect().grow(WARP_OFFSET)
		#
		#mouse_pos.x = wrapf(mouse_pos.x, view.position.x, view.end.x)
		#mouse_pos.y = wrapf(mouse_pos.y, view.position.y, view.end.y)
		#Input.warp_mouse(mouse_pos)

func _handle_widget_selection(event: InputEvent) -> void:
	if event.is_action_pressed(&"multi_select"):
		_multi_select_active = true
	elif event.is_action_released(&"multi_select"):
		_multi_select_active = false
	_handle_drag_selection(event)

#region properties handling


func _get_drag_vector(current_drag_pos: Vector2) -> Vector2:
	var snap := Input.is_action_pressed("multi_select")
	var displacement := current_drag_pos - _drag_start_pos
	if snap:
		displacement = displacement.snapped(Vector2(64, 64))
	return displacement

func _handle_node_dragging(event: InputEvent) -> void:
	#_handle_drag_selection(event)
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

#region Widget Selection

# Handler for node selection on visual widgets
#func _handle_widget_selection(event: InputEvent):
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		#if event.pressed:
			## Init selection and clear previous selection
			#_selection_mouse_pressed = true
			#_selection_start_pos = _viewport.get_camera_2d().get_global_mouse_position()
			#_clear_selection()
				#
			## Click time handling
			#var current_time = Time.get_ticks_msec() / 1000.0
			#var is_double_click = (current_time - _last_click_time) < _DOUBLE_CLICK_TIME
			#_last_click_time = current_time
#
			## get selection on area
			#var mouse_pos = _viewport.get_camera_2d().get_global_mouse_position()
			#var selected = _get_selected_nodes_on_click(Rect2(mouse_pos - Vector2(1, 1), Vector2(2, 2)))
			#
			#if is_double_click and selected.size() > 0: # Single node selection
				#var closest_node: ClassLeaf = _find_closest_node_to_center(selected, mouse_pos)
				##if closest_node:
					##_bus_core.current_node_changed.emit(closest_node)
				#_selection_mouse_pressed = false
				#return
		#else:
			#if _selection_mouse_pressed:
				#_selection_mouse_pressed = false
#
				#if _drag_selection_enabled:
					#_finish_drag_selection()
				#else: # Single area selection
					#var mouse_pos = _viewport.get_camera_2d().get_global_mouse_position()
					#var selected = _get_selected_nodes_on_click(Rect2(mouse_pos - Vector2(1, 1), Vector2(2, 2)))
					##_bus.whiteboard_nodes_selected.emit(selected)
	#elif event is InputEventMouseMotion and _selection_mouse_pressed:
		#var current_pos = _viewport.get_camera_2d().get_global_mouse_position()
		#var dist = _selection_start_pos.distance_to(current_pos)
#
		#if dist > _SELECTION_THRESHOLD and not _drag_selection_enabled:
			#_start_drag_selection(_selection_start_pos)
		#
		#if _drag_selection_enabled:
			#_update_drag_selection(event)


# Selection helper to get all nodes under a given area
#func _get_selected_nodes_on_click(area: Rect2) -> Array[ClassLeaf]:
	#var nodes:= NodeController.get_visible_nodes()
	#var selected: Array[ClassLeaf] = []
	#
	#for node in nodes:
		#var widget: Widget = node._node_controller.leaf_value
		#if not is_instance_valid(widget):
			#continue
		##var widget_rect := widget.get_rect_bound()
		##var global_widget_rect = Rect2(
			##widget.to_global(widget_rect.position),
			##widget_rect.size
		##)
		##if area.intersects(global_widget_rect):
			##selected.append(node)
	#return selected

# Helper to find the closest node to the center of the widget
#func _find_closest_node_to_center(nodes: Array[ClassLeaf], click_pos: Vector2) -> ClassLeaf:
	#var closest_node: ClassLeaf = null
	#var min_distance: float = INF
#
	#for node in nodes:
		#var widget: Widget = node._node_controller.leaf_value
		#if not is_instance_valid(widget):
			#continue
		#
		##var widget_rect := widget.get_rect_bound()
		#
		## Get click-center distance
		##var center_pos = widget.to_global(widget_rect.get_center())
		##var distance = click_pos.distance_to(center_pos)
#
		##if distance < min_distance:
			##min_distance = distance
			##closest_node = node
	#return closest_node

#endregion

#region Drag Selection

func _handle_drag_selection(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		_dragging = button_event.is_pressed()
		if button_event.is_pressed():
			var current_pos := _viewport.get_camera_2d().get_global_mouse_position()
			_start_drag_selection(current_pos)
		else:
			_finish_drag_selection(not Input.is_action_pressed("multi_select"))
	elif event is InputEventMouseMotion:
		var motion_event := event as InputEventMouseMotion
		if _dragging:
			_update_drag_selection(motion_event)

func _start_drag_selection(start_pos: Vector2):
	_selection_box.begin_selection(start_pos)

func _update_drag_selection(_event: InputEventMouseMotion):
	var current_pos := _viewport.get_camera_2d().get_global_mouse_position()
	_selection_box.update_selection(current_pos)
	
func _finish_drag_selection(reset_selection: bool):
	#if reset_selection:
		#_clear_widget_selection()
	_selection_box.confirm_selection()

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

#func _highlight_selected_widgets() -> void:
	#for widget in _selected_widgets:
		#widget.select()
#
#func select_widget(widget: VisualEntityWidget, multi_select: bool, unselectable: bool) -> void:
	#if not multi_select:
		#_clear_widget_selection()
	#if widget in _selected_widgets and unselectable:
		#widget.deselect()
		#_selected_widgets.erase(widget)
	#else:
		#widget.select()
		#_selected_widgets.append(widget)
	#print(_selected_widgets)

func _on_widgets_selected(widgets: Array[VisualEntityWidget], multi_select: bool) -> void:
	prints("Selected widgets", widgets, "Multi select:", multi_select)
	print(_selected_widgets)
	if widgets.size() == 1 and widgets[0] in _selected_widgets \
		and (_selected_widgets.size() == 1 or multi_select):
			widgets[0].deselect()
			_selected_widgets.erase(widgets[0])
			return
	if not multi_select:
		_clear_widget_selection()
	for widget in widgets:
		if widget in _selected_widgets: continue
		widget.select()
		_selected_widgets.append(widget)
	
