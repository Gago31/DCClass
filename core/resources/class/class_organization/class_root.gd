class_name ClassRoot
extends ClassGroup

## The root of the class tree.
##
## Most of its behavior is inherited from [ClassGroup] and for consistency
## it shouldn't be overriden.


func get_printable_data() -> String:
	return "Root"

func copy() -> ClassNode:
	return null

func get_widget() -> PackedScene:
	return preload("uid://qkunlp2hjux0")

func _setup_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, "Root")

func _to_string() -> String:
	var s: String = "Root\n"
	s += _children_to_str(1)
	return s
