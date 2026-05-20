class_name PausePlaybackEntity
extends Entity

## Represents a forced pause.


func get_class_name() -> String:
	return "PausePlaybackEntity"

func get_editor_name() -> String:
	return "Pause"

func get_widget() -> PackedScene:
	return preload("uid://bjangwmut685w")

func config_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, get_editor_name())
