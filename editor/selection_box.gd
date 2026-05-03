class_name SelectionBox
extends Control


signal widgets_selected(widgets: Array[VisualEntityWidget], multi: bool)


@export var fill_color := Color(0.2, 0.5, 1.0, 0.3)
@export var border_color := Color(0.2, 0.5, 1.0, 0.8)
@export var border_width := 2.0
var rect: Rect2
var _start_pos: Vector2
var _current_pos: Vector2
var _selected_widgets: Array[VisualEntityWidget] = []
@onready var _area: Area2D = %Area2D
@onready var collision_shape: CollisionShape2D = %CollisionShape2D

func _ready() -> void:
	hide()
	collision_shape.disabled = true

func begin_selection(start_pos: Vector2) -> void:
	show()
	_selected_widgets.clear()
	_start_pos = start_pos
	_current_pos = _start_pos
	_update_rect()

func update_selection(current_pos: Vector2) -> void:
	_current_pos = current_pos
	_update_rect()

func cancel_selection() -> void:
	hide()
	_start_pos = Vector2.ZERO
	_current_pos = Vector2.ZERO

func confirm_selection() -> void:
	_update_collision()
	await get_tree().physics_frame
	collision_shape.disabled = false
	await get_tree().physics_frame
	collision_shape.disabled = true
	var multi_select := Input.is_action_pressed("multi_select")
	widgets_selected.emit(_selected_widgets, multi_select)
	hide()

func _update_collision() -> void:
	var shape := collision_shape.shape as RectangleShape2D
	_area.global_position = rect.position + rect.size * 0.5
	shape.size = rect.size

func _update_rect() -> void:
	var top_left := Vector2(
		minf(_start_pos.x, _current_pos.x),
		minf(_start_pos.y, _current_pos.y)
	)
	var bottom_right := Vector2(
		maxf(_start_pos.x, _current_pos.x),
		maxf(_start_pos.y, _current_pos.y)
	)
	rect = Rect2(top_left, bottom_right - top_left)
	queue_redraw()

func _draw():
	draw_rect(rect, fill_color)
	draw_rect(rect, border_color, false, border_width)

func _on_area_2d_area_entered(area: Area2D) -> void:
	_selected_widgets.append((area as SelectionArea).get_widget())
