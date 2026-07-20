class_name WaitEntity
extends Entity


func get_editor_name() -> String:
	return "Wait"

func get_widget() -> PackedScene:
	return preload("uid://dufk0t736w6fr")

func _on_value_updated_from_editor(item: TreeItem) -> void:
	var time_string := item.get_text(1)
	_set_time_from_string(time_string)

func _set_time_from_string(s: String) -> void:
	var valid := TimeString.is_valid(s)
	if not valid:
		_set_item_time_string()
		return
	duration = TimeString.to_seconds(s)
	_set_item_time_string()

func _set_item_time_string() -> void:
	_tree_item.set_text(1, TimeString.from_seconds(duration))

func config_editor_tree_item(item: TreeItem) -> void:
	_tree_item = item
	item.set_text(0, get_editor_name())
	item.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
	_set_item_time_string()
	item.set_editable(1, true)
