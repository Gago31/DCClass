class_name LineEntity
extends VisualEntity


## An [Entity] that represents a line


## The points that define the line.
@export var points: PackedVector2Array:
	set=set_points

## An optimized array of points
## @experimental
var points_opt: Array[Vector2i]:
	set=set_points_opt

## The delays between each point in the line.
var delays: Array[float]:
	set=set_delays

## An optimized array of delays, to store them more efficiently.
## @experimental
@export_storage var delays_opt: PackedInt32Array:
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
	points_opt.resize(points.size())
	for i in points.size():
		var v := points[i]
		var opt_v := Vector2i(floori(v.x * 1000), floori(v.y * 1000))
		points_opt[i] = opt_v

## Sets the optimized array of points, and builds the normal points.
## @experimental
func set_points_opt(value: Array[Vector2i]) -> void:
	points_opt = value.duplicate()
	points.resize(points_opt.size())
	for i in points_opt.size():
		points[i].x = points_opt[i].x * 0.001
		points[i].y = points_opt[i].y * 0.001

## Sets the array of delays, and builds the optimized array.
## @experimental
func set_delays(value: Array[float]) -> void:
	delays = value
	delays_opt.resize(delays.size())
	for i in delays.size():
		delays_opt[i] = floori(delays[i] * 1000)

## Sets the optimized array of points, and builds the normal array.
## @experimental
func set_delays_opt(value: PackedInt32Array) -> void:
	delays_opt = value
	delays.resize(delays_opt.size())
	for i in delays_opt.size():
		delays[i] = delays_opt[i] * 0.001

## Computes the total real duration of the line based on the delays.
func compute_duration() -> float:
	var total_duration: float = 0.0
	for delay in delays:
		total_duration += delay
	return total_duration

func config_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, get_editor_name())
