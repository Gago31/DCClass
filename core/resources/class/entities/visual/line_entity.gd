# 1. class name: fill the class name
class_name LineEntity
extends VisualEntity

# 2. docs: use docstring (##) to generate docs for this file
## An [Entity] that represents a line

# 3. signals: define signals here

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here

# The points that define the line.
@export var points: PackedVector2Array

# The delays between each point in the line.
@export var delays: Array[float]

# The color of the line
@export var pen_color: Color = Color.WHITE

# The thickness of the line
@export var pen_thickness: float = 3.0

# TODO: add property variables
# 7. public variables: define all public variables here

# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here
func get_class_name() -> String:
	return "LineEntity"

func get_editor_name() -> String:
	return "Line: " + str(len(points)) + " points"

func get_widget() -> PackedScene:
	return preload("uid://dyh75vkj58pw3")
	

## Serialize to a dictionary format(.json) for saving.
#func serialize() -> Dictionary:
	#var points_array: Array = Array(points)
	#return {
		#"entity_id": entity_id,
		#"entity_type": get_class_name(),
		#"duration": duration,
		#"points": points_array.map(func(v): return {"x": v.x, "y": v.y}),
		#"delays": delays,
		#"color_r": pen_color.r,
		#"color_g": pen_color.g,
		#"color_b": pen_color.b,
		#"color_a": pen_color.a,
		#"thickness": pen_thickness
	#}

# Load data from a dictionary format(.json) to resource(LineEntity).
#func load_data(data: Dictionary) -> void:
	#var points_array: Array = []
	#for point in data["points"]:
		#points_array.append(Vector2(point["x"], point["y"]))
	#points = PackedVector2Array(points_array)
	#delays = data["delays"]
	#duration = compute_duration()
	#
	#if data.has("color_r"):
		#pen_color = Color(
			#data["color_r"],
			#data["color_g"],
			#data["color_b"],
			#data["color_a"]
		#)
	#
	#if data.has("pen_thickness"):
		#pen_thickness = data["thickness"]

# Compute the total real duration of the line based on the delays.
func compute_duration() -> float:
	var total_duration: float = 0.0
	for delay in delays:
		total_duration += delay
	return total_duration

func config_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, get_editor_name())

# 13. private methods: define all private methods here, use _ as preffix

# 14. subclasses: define all subclasses here
