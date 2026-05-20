@abstract
class_name ClassNodeWidget
extends Widget


var _node: ClassNode:
	set=set_class_node,
	get=get_class_node

func set_class_node(node: ClassNode) -> void:
	_node = node

func get_class_node() -> ClassNode:
	return null

@abstract func is_leaf() -> bool;
@abstract func _jump_to_node(node: ClassNode) -> bool;
@abstract func _compute_start_time() -> float;
@abstract func _compute_end_time() -> float;
@abstract func clear_until(widget: Widget) -> bool;
@abstract func unclear() -> void;
@abstract func search_widget_by_class_node(node: ClassNode) -> ClassNodeWidget;
@abstract func jump_to_widget(target_widget: Widget) -> bool;
