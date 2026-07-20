class_name LineEntity
extends VisualEntity


## An [Entity] that represents a line


## The points that define the line.
var points: PackedVector2Array:
	set=set_points

## An optimized array of points
## @experimental
@export var points_opt: PackedByteArray:
	set=set_points_opt

## The delays between each point in the line.
var delays: Array[float]:
	set=set_delays

## An optimized array of delays, to store them more efficiently.
## @experimental
@export var delays_opt: PackedInt32Array:
	set=set_delays_opt


func get_class_name() -> String:
	return "LineEntity"

func get_editor_name() -> String:
	return "Line: " + str(len(points)) + " points"

func get_widget() -> PackedScene:
	return preload("uid://dyh75vkj58pw3")

## Sets the points of the line, and builds the optimized array in the process.
## @experimental
func set_points(value: PackedVector2Array) -> void:
	points = value
	if points_opt.size() == points.size(): return
	var opt: PackedByteArray = []
	
	opt.resize(points.size() * 4)
	for i in points.size():
		var prev := transform.origin if i == 0 else points[i - 1]
		var diff_v := points[i] - prev
		var opt_x := floori(diff_v.x * 100)
		var opt_y := floori(diff_v.y * 100)
		#var opt_v := (opt_x << 16) + opt_y
		opt.encode_s16(4 * i, opt_x)
		opt.encode_s16(4 * i + 2, opt_y)
	points_opt = opt
	#print("Set optimized points: \nreal: ", points, "\nopt: ", points_opt)

## Sets the optimized array of points, and builds the normal points.
## @experimental
func set_points_opt(value: PackedByteArray) -> void:
	points_opt = value
	if points_opt.size() == points.size() * 4: return
	var real_points: PackedVector2Array = []
	real_points.resize(points_opt.size() / 4)
	real_points[0] = Vector2.ZERO
	var acc := Vector2.ZERO
	for i in real_points.size():
		if i == 0: continue
		var x := points_opt.decode_s16(4 * i) * 0.01
		var y := points_opt.decode_s16(4 * i + 2) * 0.01
		var diff := Vector2(x, y)
		acc += diff
		real_points[i] = acc
	points = real_points

## Sets the array of delays, and builds the optimized array.
## @experimental
func set_delays(value: Array[float]) -> void:
	delays = value.duplicate()
	if delays_opt.size() == delays.size(): return
	#if delays_opt.size() == delays.size() * 2: return
	var optimized_delays: PackedInt32Array = []
	#var optimized_delays: PackedByteArray = []
	optimized_delays.resize(delays.size())
	#optimized_delays.resize(delays.size() * 2)
	for i in delays.size():
		#optimized_delays.encode_u16(2 * i, floori(delays[i] * 1000))
		optimized_delays[i] = floori(delays[i] * 1000)
	delays_opt = optimized_delays

## Sets the optimized array of points, and builds the normal array.
## @experimental
func set_delays_opt(value: PackedInt32Array) -> void:
	delays_opt = value  
	if delays_opt.size() == delays.size(): return
	var delays_real: Array[float] = []
	delays_real.resize(delays_opt.size())
	#delays_real.resize(delays_opt.size() / 2)
	for i in delays_opt.size():
		#delays_real[i] = delays_opt.decode_u16(2 * i) * 0.001
		delays_real[i] = delays_opt[i] * 0.001
	delays = delays_real

## Computes the total real duration of the line based on the delays.
func compute_duration() -> float:
	var total_duration: float = 0.0
	for delay in delays:
		total_duration += delay
	return total_duration

func config_editor_tree_item(item: TreeItem) -> void:
	_tree_item = item
	item.set_text(0, get_editor_name())
	var pi := transform.origin + points[0]
	var pf := transform.origin + points[-1]
	var coord_str := str(pi) + " --> " + str(pf)
	item.set_text(1, coord_str)
