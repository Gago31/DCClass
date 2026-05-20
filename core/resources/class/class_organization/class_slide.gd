class_name ClassSlide
extends ClassGroup

## A [ClassGroup] that has the additional property of hiding itself once it
## has finished playing.
##
## Most of its behavior is inherited from [ClassGroup] and for consistency
## it shouldn't be overriden.

func get_class_name() -> String:
	return "ClassSlide"

func get_widget() -> PackedScene:
	return preload("uid://c2gmvcijrse7y")

func get_printable_data() -> String:
	return "Slide: %s" % _name

func _setup_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, "Slide:")
	item.set_text(1, _name)
	item.set_editable(1, true)

func _on_value_updated_from_editor(item: TreeItem) -> void:
	var new_name := item.get_text(1)
	_name = new_name

func _to_string() -> String:
	return "Slide: %s" % _name
