class_name ClearEntity
extends Entity


## An [Entity] for a clear operation. It signals that the previous elements
## inside its group should be hidden.


func get_class_name() -> String:
	return "ClearEntity"

func get_editor_name() -> String:
	return "Clear"

func get_widget() -> PackedScene:
	return preload("uid://b8obtgkbi1jwp")

func config_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, get_editor_name())
