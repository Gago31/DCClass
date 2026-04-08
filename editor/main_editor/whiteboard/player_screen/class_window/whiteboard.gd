extends Control

const WARP_OFFSET := -10
const SQUARED_THRESHOLD := 4.0

@onready var _bus: EditorEventBus = Engine.get_singleton(&"EditorSignals")
@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")
@onready var _viewport_container: SubViewportContainer = %SubViewportContainer
@onready var _viewport: SubViewport = %SubViewport

var camera: ClassCameraEditor

var _dragging: bool = false
var _warped: bool = false

# pen
var _pen_enabled: bool = false
var _pressed: bool = false
var _line: Line2D
var _last_point: Vector2 = Vector2.INF

var _pen_thickness: float = 3.0
var _pen_color: Color = Color.WHITE

# Node selection
var _node_drag_enabled: bool = false
var _current_node: ClassNode
var _nodes_to_drag: Array[ClassLeaf]
var _selected_nodes: Array[ClassLeaf]
var _last_click_time: float = 0.0
const _DOUBLE_CLICK_TIME: float = 0.2
# Node dragging
var _node_dragging: bool = false
var _drag_start_pos: Vector2
var _nodes_start_pos: Array[Vector2]
# Drag selection
var _drag_selection_enabled: bool = false
var _drag_selection_start: Vector2
var _drag_selection_rect: Rect2
var _selection_box: Control
# Node Resizing
var _node_resize_enabled: bool = false
var _resizing:= false
var _resize_start_pos: Vector2
var _resize_start_size: Vector2
var _resize_handle_size: float = 10.0
var _expanded_margin: float = 20.0
var _nodes_to_resize: Array[ClassLeaf]
var _nodes_start_sizes: Array[Vector2]
# Selection state
var _selection_mouse_pressed: bool = false
var _selection_start_pos: Vector2
const _SELECTION_THRESHOLD = 0.5

func _ready() -> void:
	_bus.pen_toggled.connect(_on_pen_toggled)
	_bus.pen_thickness_changed.connect(_on_pen_thickness_changed)
	_bus.pen_color_changed.connect(_on_pen_color_changed)
	_bus.drag_toggled.connect(_on_node_drag_enabled)
	_bus.resize_toggled.connect(_on_node_resize_enabled)
	_bus_core.current_node_changed.connect(_current_node_changed)
	_bus_core.subtitles_updated.connect(_on_subtitles_updated)
	_bus.class_node_selected.connect(_on_class_node_selected)
	_bus.clear_selection.connect(_clear_selection)

	_create_selection_box()


func _gui_input(event):
	if _pen_enabled:
		_bus.pen_started_drawing.emit()
		_handle_drawing(event)
		return

	if _node_drag_enabled:
		_handle_node_dragging(event)
		return

	# if _node_drag_enabled:
	# 	_handle_node_dragging(event)
	# 	return
	
	if _node_resize_enabled:
		_handle_node_resize(event)
		return
	
	if not (_pen_enabled or _node_drag_enabled):
		_handle_widget_selection(event)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		_dragging = event.is_pressed()
	elif event is InputEventMouseMotion and _dragging:
		get_viewport().set_input_as_handled()
		
		if _warped:
			_warped = false
			return

		if not is_instance_valid(camera):
			camera = _viewport.get_camera_2d()
			if not is_instance_valid(camera):
				printerr("Trying to move but no camera available")
				return

		camera.user_controlled = true
		camera.position -= event.relative

		var mouse_pos: Vector2 = event.global_position
		var view := get_global_rect().grow(WARP_OFFSET)
		_warped = not view.has_point(mouse_pos)

		if mouse_pos.x < view.position.x:
			mouse_pos.x = view.end.x
		elif mouse_pos.x > view.end.x:
			mouse_pos.x = view.position.x
		if mouse_pos.y < view.position.y:
			mouse_pos.y = view.end.y
		elif mouse_pos.y > view.end.y:
			mouse_pos.y = view.position.y

		if _warped:
			Input.warp_mouse(mouse_pos)
			
var _delays: Array[float] = []
var _last_time: float = 0.0

func _on_pen_toggled(active: bool) -> void:
	_pen_enabled = active
	_last_time = Time.get_ticks_msec() / 1000.0

func _on_pen_thickness_changed(thickness: float) -> void:
	_pen_thickness = thickness
	
func _on_pen_color_changed(color: Color) -> void:
	_pen_color = color

func _on_node_drag_enabled(enabled: bool) -> void:
	_node_drag_enabled = enabled

func _on_node_resize_enabled(enabled: bool) -> void:
	_node_resize_enabled = enabled

func _on_class_node_selected(node: ClassNode, selected: bool) -> void:
	if node == _current_node:
		return
	var controller = node._node_controller
	if node is ClassLeaf: # Case ClassLeaf
		if selected:
			_selected_nodes.append(node)
		else:
			_selected_nodes.erase(node)

# Callback to deselect all selected nodes
func _clear_selection():
	_selected_nodes.clear()

func _handle_drawing(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not is_instance_valid(_viewport):
			return
		var pos: Vector2 = _viewport.get_camera_2d().get_global_mouse_position()
		
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			var now = Time.get_ticks_msec() / 1000.0

			if not _pressed:
				_pressed = true
				
				_bus.pen_thickness_changed.emit(_pen_thickness)
				_bus.pen_color_changed.emit(_pen_color)
				
				_line = _new_line()
				_viewport.add_child(_line)
				_line.add_point(pos)
				_last_point = pos
				
				_delays.clear()
				var delta_time = now - _last_time
				if delta_time > 10:
					delta_time = 10
				_delays.append(delta_time)
				_last_time = now
			else:
				_line.set_point_position(_line.get_point_count() - 1, pos)

				if _last_point.distance_squared_to(pos) > SQUARED_THRESHOLD:
					_line.add_point(pos)
					var delta_time = now - _last_time
					if delta_time > 5:
						delta_time = 5
					_delays.append(delta_time)
					_last_time = now
					_last_point = pos

		elif _pressed:
			_line.add_point(pos)
			_pressed = false

			var now = Time.get_ticks_msec() / 1000.0
			var delta_time = now - _last_time
			if delta_time > 10:
				delta_time = 10
			_delays.append(delta_time)

			var entity := LineEntity.new()
			entity.points = _line.points
			entity.pen_color = _pen_color
			entity.pen_thickness = _pen_thickness
			
			var _position_origin: Vector2 = _line.points[0]
			for i in range(entity.points.size()):
				entity.points[i] -= _position_origin
			
			entity.delays = _delays.duplicate()
			entity.duration = entity.compute_duration()
			var new_entity_properties = [
									{
										"position:x": _position_origin.x,
										"position:y": _position_origin.y,
										"property_type": "PositionEntityProperty"
									}
								]

			_bus.emit_signal("add_class_leaf_entity", entity, new_entity_properties)
			
			var parent = _line.get_parent()
			
			parent.remove_child(_line)
			_line.queue_free()
			_line = null

#region properties handling

func _handle_node_dragging(event: InputEvent) -> void:
	if not _current_node:
		return
	
	# Start Drag case
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var controller = _current_node._node_controller
			_nodes_start_pos.clear()
			_nodes_to_drag.clear()
			
			# Case when current node is a Leaf and is not an audio
			if controller is LeafController and not controller.is_audio():
				_nodes_to_drag.append(_current_node)
				var position = _current_node.get_properties().get("position")
				if position is Vector2:
					_nodes_start_pos.append(position)
			# Case when current node is a Group and his TreeItem is collapsed
			elif controller is GroupController:
				# Get all nodes added to the skipped visual group
				for node_controller in get_tree().get_nodes_in_group(&"skipped_before_play"):
					if node_controller is LeafController:
						var class_node: ClassLeaf = node_controller._class_node
						_nodes_to_drag.append(class_node)
						var position = class_node.get_properties().get("position")
						if position is Vector2:
							_nodes_start_pos.append(position)
			else:
				return
			
			# Add selected nodes to the drag
			for node in _selected_nodes:
				_nodes_to_drag.append(node)
				var position = node.get_properties().get("position")
				if position is Vector2:
					_nodes_start_pos.append(position)
			
			_dragging = true
			_drag_start_pos = _viewport.get_camera_2d().get_global_mouse_position()
		else:
			# Execute after release button
			if _dragging:
				_nodes_start_pos.clear()
				_nodes_to_drag.clear()
				_dragging = false
				_bus.clear_selection.emit()
			return
	# Dragging case
	elif event is InputEventMouseMotion and _dragging:
		if not is_instance_valid(_viewport) or not _current_node:
			return
		var controller = _current_node._node_controller
		
		# Check if current node is a Visual Widget
		if controller is LeafController and controller.is_audio():
			print("No visual")
			return

		# Get an drag offset to apply to all nodes by its own origin previous to the drag
		var pos: Vector2 = _viewport.get_camera_2d().get_global_mouse_position()
		var offset: Vector2 = pos - _drag_start_pos

		for i in range(len(_nodes_to_drag)):
			var position = _nodes_to_drag[i].get_properties().get("position")
			if position is Vector2:
				_nodes_start_pos.append(position)
				position = _nodes_start_pos[i] + offset
				var new_prop = PositionEntityProperty.new()
				new_prop.position = position
				_nodes_to_drag[i].set_property(new_prop)

func _handle_node_resize(event: InputEvent) -> void:
	if not _current_node:
		return

	# Resize init
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var controller = _current_node._node_controller
			_nodes_start_sizes.clear()
			_nodes_to_resize.clear()

			# Case when current node is a Leaf and is not an audio
			if controller is LeafController and not controller.is_audio():
				var widget: Widget = controller.leaf_value
				if not is_instance_valid(widget):
					return
				var size = widget.get_rect_bound().size
				if size != Vector2.ZERO:
					_nodes_to_resize.append(_current_node)
					_nodes_start_sizes.append(size)
					_resize_start_size = size
			
			# Add selected nodes to the resize
			for node in _selected_nodes:
				var node_controller = node._node_controller
				if node_controller is LeafController and not node_controller.is_audio():
					var widget: Widget = node_controller.leaf_value
					if not is_instance_valid(widget):
						continue
					var size = widget.get_rect_bound().size
					if size != Vector2.ZERO:
						_nodes_to_resize.append(node)
						_nodes_start_sizes.append(size)

			_resizing = true
			_resize_start_pos = _viewport.get_camera_2d().get_global_mouse_position()
	
		else:
			# Execute after release button
			if _resizing:
				_resizing = false
				_nodes_start_sizes.clear()
				_nodes_to_resize.clear()
				_bus.clear_selection.emit()
	elif event is InputEventMouseMotion and _resizing:
		if not is_instance_valid(_viewport) or not _current_node:
			return
		
		# Get an resize offset to apply to all nodes by its own origin previous to the resize
		var pos: Vector2 = _viewport.get_camera_2d().get_global_mouse_position()
		var offset: Vector2 = pos - _resize_start_pos

		var scale_x = 1.0
		var scale_y = 1.0

		if _resize_start_size.x > 0:
			scale_x = max (0.1, (_resize_start_size.x + offset.x) / _resize_start_size.x)
		if _resize_start_size.y > 0:
			scale_y = max (0.1, (_resize_start_size.y + offset.y) / _resize_start_size.y)

		for i in range(len(_nodes_to_resize)):
			var size = _nodes_to_resize[i].get_properties().get("size")
			var original_size = _nodes_start_sizes[i]
			var new_size = Vector2(
				original_size.x * scale_x,
				original_size.y * scale_y
			)

			new_size.x = max(new_size.x, 20)
			new_size.y = max(new_size.y, 20)

			var new_prop := SizeEntityProperty.new()
			new_prop.size = new_size
			_nodes_to_resize[i].set_property(new_prop)

#endregion

#region Widget Selection

# Handler for node selection on visual widgets
func _handle_widget_selection(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			# Init selection and clear previous selection
			_selection_mouse_pressed = true
			_selection_start_pos = _viewport.get_camera_2d().get_global_mouse_position()
			_clear_selection()
				
			# Click time handling
			var current_time = Time.get_ticks_msec() / 1000.0
			var is_double_click = (current_time - _last_click_time) < _DOUBLE_CLICK_TIME
			_last_click_time = current_time

			# get selection on area
			var mouse_pos = _viewport.get_camera_2d().get_global_mouse_position()
			var selected = _get_selected_nodes_on_click(Rect2(mouse_pos - Vector2(1, 1), Vector2(2, 2)))
			
			if is_double_click and selected.size() > 0: # Single node selection
				var closest_node: ClassLeaf = _find_closest_node_to_center(selected, mouse_pos)
				if closest_node:
					_bus_core.current_node_changed.emit(closest_node)
				_selection_mouse_pressed = false
				return
		else:
			if _selection_mouse_pressed:
				_selection_mouse_pressed = false

				if _drag_selection_enabled:
					_finish_drag_selection()
				else: # Single area selection
					var mouse_pos = _viewport.get_camera_2d().get_global_mouse_position()
					var selected = _get_selected_nodes_on_click(Rect2(mouse_pos - Vector2(1, 1), Vector2(2, 2)))
					_bus.whiteboard_nodes_selected.emit(selected)
	elif event is InputEventMouseMotion and _selection_mouse_pressed:
		var current_pos = _viewport.get_camera_2d().get_global_mouse_position()
		var dist = _selection_start_pos.distance_to(current_pos)

		if dist > _SELECTION_THRESHOLD and not _drag_selection_enabled:
			_start_drag_selection(_selection_start_pos)
		
		if _drag_selection_enabled:
			_update_drag_selection(event)


# Selection helper to get all nodes under a given area
func _get_selected_nodes_on_click(area: Rect2) -> Array[ClassLeaf]:
	var nodes:= NodeController.get_visible_nodes()
	var selected: Array[ClassLeaf] = []
	
	for node in nodes:
		var widget: Widget = node._node_controller.leaf_value
		if not is_instance_valid(widget):
			continue
		var widget_rect := widget.get_rect_bound()
		var global_widget_rect = Rect2(
			widget.to_global(widget_rect.position),
			widget_rect.size
		)
		if area.intersects(global_widget_rect):
			selected.append(node)
	return selected

# Helper to find the closest node to the center of the widget
func _find_closest_node_to_center(nodes: Array[ClassLeaf], click_pos: Vector2) -> ClassLeaf:
	var closest_node: ClassLeaf = null
	var min_distance: float = INF

	for node in nodes:
		var widget: Widget = node._node_controller.leaf_value
		if not is_instance_valid(widget):
			continue
		
		var widget_rect := widget.get_rect_bound()
		
		# Get click-center distance
		var center_pos = widget.to_global(widget_rect.get_center())
		var distance = click_pos.distance_to(center_pos)

		if distance < min_distance:
			min_distance = distance
			closest_node = node
	return closest_node

#endregion

#region Drag Selection

# Create a selection box control to visualize the drag selection
func _create_selection_box():
	_selection_box = SelectionBox.new()
	_selection_box.name = "SelectionBox"
	_selection_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_selection_box.visible = false
	_viewport.add_child(_selection_box)

# Drag selection handler: start
func _start_drag_selection(start_pos: Vector2):
	_drag_selection_enabled = true
	_drag_selection_start = start_pos
	_drag_selection_rect = Rect2(start_pos, Vector2.ZERO)
	_selection_box.visible = true
	_selection_box.position = start_pos
	_selection_box.size = Vector2.ZERO

# Drag selection handler: update
func _update_drag_selection(event: InputEventMouseMotion):
	if not _drag_selection_enabled:
		return
	
	# Get rect bounds from start to current mouse pos
	var current_pos = _viewport.get_camera_2d().get_global_mouse_position()
	var top_left = Vector2(
		min(_drag_selection_start.x, current_pos.x),
		min(_drag_selection_start.y, current_pos.y)
	)
	var bottom_right = Vector2(
		max(_drag_selection_start.x, current_pos.x),
		max(_drag_selection_start.y, current_pos.y)
	)

	_drag_selection_rect = Rect2(top_left, bottom_right - top_left)

	# Update selection box visual
	_selection_box.position = _drag_selection_rect.position
	_selection_box.size = _drag_selection_rect.size
	_selection_box.queue_redraw()
	
# Drag selection handler: finish
func _finish_drag_selection():
	_drag_selection_enabled = false
	_selection_box.visible = false

	# Get selected nodes in the selection rectangle and emit selection
	var selected = _get_selected_nodes_on_click(_drag_selection_rect)	
	_bus.whiteboard_nodes_selected.emit(selected)

# Helper class to simulate desktop selection box
class SelectionBox extends Control:
	func _draw():
		var rect = Rect2(Vector2.ZERO, size)
		var fill_color = Color(0.2, 0.5, 1.0, 0.3)
		var border_color = Color(0.2, 0.5, 1.0, 0.8)
		var border_width = 2.0
		
		# Draw and fill
		draw_rect(rect, fill_color)
		draw_rect(rect, border_color, false, border_width)

#endregion

func _new_line() -> Line2D:
	var l := Line2D.new()
	l.width = _pen_thickness
	l.default_color = _pen_color
	l.begin_cap_mode = Line2D.LINE_CAP_ROUND
	l.end_cap_mode = Line2D.LINE_CAP_ROUND
	l.joint_mode = Line2D.LINE_JOINT_ROUND
	l.antialiased = true
	return l

func _current_node_changed(node: ClassNode) -> void:
	_current_node = node
	_bus.clear_selection.emit()

func _on_subtitles_updated(text: String) -> void:
	$MarginContainer/Subtitles.parse_bbcode(text)
