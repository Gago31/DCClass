class_name ClassRoot
extends ClassGroup


func _setup_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, "Root")

func get_printable_data() -> String:
	return "Root"

func copy() -> ClassNode:
	return null

func _to_string() -> String:
	var s: String = "Root\n"
	s += _children_to_str(1)
	return s

func get_widget() -> PackedScene:
	return preload("uid://qkunlp2hjux0")
