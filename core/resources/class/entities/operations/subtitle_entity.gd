class_name SubtitleEntity
extends Entity

## An [Entity] that represent an update to the subtitles of the class.


## The text that will be shown in the subtitles. Supports the use of BBcode.
@export var text: String


func get_class_name() -> String:
	return "SubtitleEntity"

func get_editor_name() -> String:
	return "Subtitles: %s" % text

func get_widget() -> PackedScene:
	return preload("uid://cgvc74n6rdute")

func config_editor_tree_item(item: TreeItem) -> void:
	_tree_item = item
	item.set_text(0, "Subtitles:")
	item.set_text(1, text)

## Sets the text of the entity and updates its editor item.
func set_text(new_text: String) -> void:
	text = new_text
	if _tree_item:
		_tree_item.set_text(1, new_text)
	updated.emit()

func _on_value_updated_from_editor(item: TreeItem) -> void:
	var new_text := item.get_text(1)
	text = new_text
