class_name SelectionArea
extends Area2D


var _widget: VisualEntityWidget
@onready var collision_shape: CollisionShape2D = %CollisionShape2D


func setup_for_widget(widget: VisualEntityWidget):
	_widget = widget
	update_collision_shape(widget)

func update_collision_shape(widget: VisualEntityWidget):
	var rect = widget.get_rect_bound()
	if rect.size == Vector2.ZERO: return
	var shape = RectangleShape2D.new()
	shape.size = rect.size
	collision_shape.shape = shape
	collision_shape.position = rect.position + rect.size * 0.5

func get_widget() -> VisualEntityWidget:
	return _widget

func _on_visibility_changed() -> void:
	collision_layer = 1 if is_visible_in_tree() else 0
