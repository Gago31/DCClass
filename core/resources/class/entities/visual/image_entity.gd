class_name ImageEntity
extends VisualEntity

## An [Entity] that represents an image inside the whiteboard.


## Notifies that the image file for this entity has already been converted and
## it's ready to be used.
signal conversion_finished(err: bool)


## The name of the image file.
@export var image_path: String


func get_class_name() -> String:
	return "ImageEntity"

func get_editor_name() -> String:
	return "Image: " + image_path

func get_widget() -> PackedScene:
	return preload("uid://bfyhdkl1lp68k")

func config_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, get_editor_name())

func _on_image_converted(_result: Variant, _path: String) -> void:
	conversion_finished.emit(true)
