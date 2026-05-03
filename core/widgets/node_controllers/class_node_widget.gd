@abstract
class_name ClassNodeWidget
extends Widget


var _node: ClassNode:
	set=set_class_node,
	get=get_class_node
#var _start_time: float = -1.0
#var _end_time: float = -1.0


func set_class_node(node: ClassNode) -> void:
	_node = node

func get_class_node() -> ClassNode:
	return null

@abstract func is_leaf() -> bool;
@abstract func _jump_to_node(node: ClassNode) -> bool;
#@abstract func _jump_to_time(time: float) -> bool;
@abstract func _compute_start_time() -> float;
@abstract func _compute_end_time() -> float;
@abstract func clear_until(widget: Widget) -> bool;
@abstract func unclear() -> void;
@abstract func search_widget_by_class_node(node: ClassNode) -> Widget;
@abstract func jump_to_widget(target_widget: Widget) -> bool;
# Meant to be used by [ClassRoot]'s `jump_to_node()`
