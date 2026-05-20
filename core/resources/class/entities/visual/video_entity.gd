class_name VideoEntity
extends VisualEntity


## An [Entity] that represents a video inside the whiteboard.

## Emitted when the video file for this entity has been converted and is ready
## to be used.
signal conversion_finished(err: bool)


## The name of the video file for this entity.
@export var video_path: String


func get_class_name() -> String:
	return "VideoEntity"

func get_editor_name() -> String:
	return "Video: " + video_path

func get_widget() -> PackedScene:
	return preload("uid://cqqmunsul4k5f")

func compute_duration() -> float:
	return 0.0 

func _on_video_converted(_result: Variant, _path: String) -> void:
	conversion_finished.emit(true)

func config_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, get_editor_name())
