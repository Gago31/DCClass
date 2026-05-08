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
	#var e := get_entity()
	_set_width_and_color()
	_load_point_data(0)
	#_points = e.points
	#_delays = []
	#_delays.resize(e.delays.size())
	#var total_delay: float = 0.0
	#for i in range(1, e.delays.size()):
		#_delays[i] = total_delay
		#total_delay += e.delays[i]
	_current_point = 0

func _smooth_curve(points: PackedVector2Array) -> PackedVector2Array:
	var temp: PackedVector2Array = []
	temp.append(points[0])
	for i in points.size() - 1:
		var p0 := points[i]
		var p1 := points[i + 1]
		var q := p0 * 0.75 + p1 * 0.25
		var r := p0 * 0.25 + p1 * 0.75
		temp.append(q)
		temp.append(r)
	temp.append(points[points.size() - 1])
	return temp

func _expand_delays(delays: Array[float]) -> Array[float]:
	var temp: Array[float] = []
	var n := delays.size()
	temp.resize(n * 2)
	for i in n - 1:
		temp[2 * i] = delays[i]
		temp[2 * i + 1] = (delays[i] + delays[i + 1]) * 0.5
	temp[2 * n - 1] = delays[n - 1]
	return temp

func _load_point_data(smoothing: int = 0) -> void:
	var e := get_entity()
	var n := e.points.size()
	# Trust me
	#var final_size := (2 ** smoothing) * (n - 1) + 1
	var total_delay := 0.0
	_points = []
	_delays = []
	_points.resize(n)
	_delays.resize(n)
	
	for i in n:
		_points[i] = e.points[i]
		if i == 0: continue
		_delays[i] = total_delay
		total_delay += e.delays[i]
	
	for i in smoothing:
		print("smoothing ", i)
		var p = _smooth_curve(_points)
		var d = _expand_delays(_delays)
		_points = p
		_delays = d
	
	#e.points
	#_points.resize(final_size)
	#_delays.resize(final_size)
	
	#var skip := 2 ** smoothing - 1
	## 0 -> 0 | 0 - 1 - 2 - 3 - 4
	## 1 -> 1 | 0 - 2 - 4 - 6 - 8
	## 2 -> 3 | 0 - 4 - 8 - 12 - 16
	## 3 -> 7 | 0 - 8 - 16 - 24 - 32
	#for i in n:
		#_points[i + i * skip] = e.points[i]
		#if i == 0: continue
		#_delays[i + i * skip] = total_delay
		#total_delay += e.delays[i]
	#
	#for s in smoothing + 1:
		#skip = 2 ** (smoothing - s) - 1
		#for i in range(0, final_size - 1, skip + 1):
			##var im := (2 * i + 1) * (skip + 1) / 2
			#var im := (2 * i + skip + 1) / 2
			##var p1 := _points[i * (skip + 1)]
			#var p1 := _points[i]
			##var p2 := _points[(i + 1) * (skip + 1)]
			#var p2 := _points[i + skip + 1]
			#var pm := (p1 + p2) * 0.5
			#_points[im] = pm
			##var d1 := _delays[i * (skip + 1)]
			#var d1 := _delays[i]
			##var d2 := _delays[(i + 1) * (skip + 1)]
			#var d2 := _delays[i + skip + 1]
			#var dm := (d1 + d2) * 0.5
			#_delays[im] = dm

func _set_width_and_color() -> void:
	line.default_color = WhiteboardManager.get_pen_color()
	line.width = WhiteboardManager.get_pen_thickness()

func _on_started_playing() -> void:
	#_set_width_and_color()
	show()

func _on_seek() -> void:
	_clear_points()
	#_set_width_and_color()
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
