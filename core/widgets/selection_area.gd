class_name SelectionArea
extends Area2D

## Area used for detecting [VisualEntityWidget]s with the [SelectionBox].

var _widget: VisualEntityWidget
@onready var collision_shape: CollisionShape2D = %CollisionShape2D


## Sets the widget of this selection area and creates its collision shape
## based on its bounds.
func setup_for_widget(widget: VisualEntityWidget):
	_widget = widget
	_update_collision_shape(widget)

## Returns the [VisualEntityWidget] associated to this selection area.
func get_widget() -> VisualEntityWidget:
	return _widget

func _update_collision_shape(widget: VisualEntityWidget):
	var rect := widget.get_rect_bound()
	if rect.size == Vector2.ZERO: return
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision_shape.shape = shape
	collision_shape.position = rect.position + rect.size * 0.5

func _on_visibility_changed() -> void:
	collision_layer = 1 if is_visible_in_tree() else 0
