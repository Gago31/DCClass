@tool
extends Node2D

@export_tool_button("print box") var btn = print_box
@onready var line_2d: Line2D = $Line2D
@onready var selection_area: SelectionArea = %SelectionArea
@onready var collision_shape_2d: CollisionShape2D = $SelectionArea/CollisionShape2D


func _ready() -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(728, 448)
	#collision_shape_2d.position = Vector2(388, 240)
	collision_shape_2d.shape = shape

func print_box() -> void:
	if not line_2d:
		print("no line")
		return
	var rid := line_2d.get_canvas_item()
	
	print(RenderingServer.debug_canvas_item_get_rect(rid))


func _on_selection_area_clicked(multi_select: bool) -> void:
	print("owo")
