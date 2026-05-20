class_name PenColorEntity
extends Entity

## An [Entity] that represents a pen color change operation.
##
## This color is only meant to apply within the group, it is not preserved 
## after exiting.

## The color that will be assigned to subsequent lines inside the [ClassGroup].
@export var color: Color


func get_widget() -> PackedScene:
	return preload("uid://cpfenn5p8def4")

func get_class_name() -> String:
	return "PenColorEntity"
	
func get_editor_name() -> String:
	return "Color: " + str(color)

func config_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, "Pen Color")
	item.set_cell_mode(1, TreeItem.CELL_MODE_CUSTOM)
	item.set_custom_as_button(1, true)
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = color
	stylebox.set_border_width_all(4)
	stylebox.border_color = Color.BLACK
	item.set_custom_stylebox(1, stylebox)

func _on_value_updated_from_editor(item: TreeItem) -> void:
	var new_color := item.get_custom_bg_color(1)
	color = new_color
