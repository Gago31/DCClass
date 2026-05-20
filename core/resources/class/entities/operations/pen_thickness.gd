class_name PenThicknessEntity
extends Entity

## An [Entity] that represents a change to the size of the pen.
##
## This size is only meant to apply within the group, it is not preserved 
## after exiting.

## The size that will be used for subsequent lines within the group.
@export var thickness: float


func get_class_name() -> String:
	return "PenThicknessEntity"

func get_editor_name() -> String:
	return "Thickness: " + str(thickness)

func get_widget() -> PackedScene:
	return preload("uid://b8pjlem1nqjal")

func config_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, "Thickness")
	item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	item.set_range_config(1, 1, 64, 1)
	item.set_range(1, thickness)
	item.set_editable(1, true)

func _on_value_updated_from_editor(item: TreeItem) -> void:
	var new_thickness := item.get_range(1)
	thickness = new_thickness
