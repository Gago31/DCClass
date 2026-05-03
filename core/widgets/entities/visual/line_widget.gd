class_name LineWidget
extends VisualEntityWidget


var tween: Tween
var bound = null
var _original_bound: Rect2
var _current_point: int = 0
var _points: PackedVector2Array
var _delays: Array[float]
@onready var line: Line2D = %Line


func _while_playing(_delta: float) -> void:
	_update_points()

func setup() -> void:
	super.setup()
	var e := get_entity()
	_points = e.points
	_delays = []
	_delays.resize(e.delays.size())
	var total_delay: float = 0.0
	for i in range(1, e.delays.size()):
		_delays[i] = total_delay
		total_delay += e.delays[i]
	_current_point = 0

func _on_started_playing() -> void:
	line.default_color = WhiteboardManager.get_pen_color()
	line.width = WhiteboardManager.get_pen_thickness()
	show()

func _on_seek() -> void:
	_clear_points()
	_current_point = 0
	#print("Line: play time = ", play_time)
	_update_points()
	show()

func _update_points() -> void:
	while play_time >= _delays[_current_point]:
		line.add_point(_points[_current_point])
		#_update_bounds()
		_current_point += 1
		if _current_point >= _points.size():
			finish_playing()
			return

func _clear_points() -> void:
	line.clear_points()

func _on_skip() -> void:
	#print("Jump to end")
	_current_point = _points.size() - 1
	line.points = _points
	show()

func _calculate_duration() -> float:
	#var total_time: float = 0.0
	#var delays := get_entity().delays
	if _delays.size() > 0:
		return _delays[-1]
	return 0.0
		#for i in range(_delays.size()):
			#total_time += _delays[i]
	#duration = total_time
	#return duration

func _update_bounds() -> void:
	bounds = _compute_bounds()
	selection_area.setup_for_widget(self)


#func _points_center(points: PackedVector2Array) -> Vector2:
	#if points.is_empty():
		#return Vector2.ZERO
	#
	#var sum_x = 0.0
	#var sum_y = 0.0
		#
	#for point in points:
		#sum_x += point.x
		#sum_y += point.y
		#
	#return Vector2(sum_x / points.size(), sum_y / points.size())

#func _notify_center(center: Vector2) -> void:
	#if ClassUIMobile.context and ClassUIMobile.context.camera:
		#var global_center = to_global(center)
		#ClassUIMobile.context.camera.add_recent_content(global_center)

# Reset the line widget to its initial state.
# This means hiding the line and clearing its points.
func _on_reset():
	_current_point = 0
	#print("Line reset")
	hide()
	_clear_points()

# Clear the line widget.
# This means resetting the line and removing it from the groups.
#func clear():
	#reset()

# Unclear the line widget.
# This means resetting to the visual state.
#func unclear():
	#jump_to_end()

# Get bounds as Array of Vector2
func get_rect_bound() -> Rect2:
	if not bound:
		bound = _compute_bounds()
	return bound

# Return the boundaries vector that contains the line
func _compute_bounds() -> Rect2:
	var points = get_entity().points
	if points.is_empty():
		return Rect2(Vector2.ZERO, Vector2.ZERO)
	
	# init with first point
	var min_x = points[0].x
	var max_x = points[0].y
	var min_y = points[0].x
	var max_y = points[0].y
	
	# find min max
	for point in points:
		min_x = min(min_x, point.x)
		min_y = min(min_y, point.y)
		max_x = max(max_x, point.x)
		max_y = max(max_y, point.y)
	
	# set the vectors
	#var origin := get_entity().transform.origin + Vector2(min_x, min_y)
	var origin := Vector2(min_x, min_y)
	var size := Vector2(max_x - min_x, max_y - min_y)
	#var tl = Vector2(min_x, min_y)
	#var br = Vector2(max_x, max_y)

	return Rect2(origin, size)

func _on_property_updated(property: EntityProperty) -> void:
	if property is PositionEntityProperty:
		position = property.position
	elif property is SizeEntityProperty:
		# Guardar el bound original si no existe
		if _original_bound == Rect2():
			_original_bound = get_rect_bound()
		
		# Si el bound original es válido, transformar los puntos
		if _original_bound.size.x > 0 and _original_bound.size.y > 0:
			var new_bound = Rect2(_original_bound.position, property.size)
			
			# Calcular la escala
			var scale_x = new_bound.size.x / _original_bound.size.x
			var scale_y = new_bound.size.y / _original_bound.size.y
			 
			# Transformar cada punto
			var new_points: PackedVector2Array = []
			for point in entity.points:
				# Normalizar punto respecto al bound original
				var normalized = (point - _original_bound.position) / _original_bound.size
				# Aplicar al nuevo bound
				var new_point = new_bound.position + (normalized * new_bound.size)
				new_points.append(new_point)
			
			# Actualizar entity y visual
			entity.points = new_points
			line.points = new_points
			
			# Invalidar bound cacheado
			bound = null
			
			# Actualizar el original bound para futuros resizes
			_original_bound = new_bound

func get_entity() -> LineEntity:
	return entity as LineEntity

#func seek(time: float, playing: bool = false) -> void:
	#super.seek(time, playing)
	#var time_str := "%02f~%02f" % [start_time, end_time]
	#prints(get_entity().get_editor_name(), "(%s)" % time_str, "seeking to t=", time, ". Play time=", play_time)
