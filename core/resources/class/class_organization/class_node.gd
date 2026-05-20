@abstract
class_name ClassNode
extends Resource

## Base class for all the nodes in the class tree.


## Emitted when a property of this node is modified. Used in the editor.
signal updated
## Emitted when the node has to be deleted. Used in the editor.
signal deleted

## Returns the name of this node's class in plain text.
## @deprecated
func get_class_name() -> String:
	return "ClassNode"

## Returns the name that this node should have inside the editor.
##
## This name should be clear and understandable for a teacher, mentioning the
## type of node that is being manipulated.
@abstract
func get_editor_name() -> String;

## Wether this node is a [ClassLeaf] or a type of [ClassGroup], so you don't
## have to check the class of an arbitrary node explicitly.
func is_leaf() -> bool:
	return false

## Sets up the [TreeItem] displayed in the control panel of the editor.[br][br]
##
## [b][color=indian_red]You shouldn't override this method.[/color][/b][br][br]
##
## To actually define how the node's item is built, override
## [method _setup_editor_tree_item].
func config_editor_tree_item(item: TreeItem) -> void:
	_setup_editor_tree_item(item)
	item.set_metadata(0, self)

## Tells the node to update itself after a change in its [TreeItem].[br][br]
##
## [b][color=indian_red]You shouldn't override this method.[/color][/b][br][br]
##
## To handle the way in which the node updates itself, override
## [method _on_value_updated_from_editor].
func update_value(item: TreeItem) -> void:
	_on_value_updated_from_editor(item)
	updated.emit()

## Returns a deep copy of this node.
func copy() -> ClassNode:
	return duplicate_deep(Resource.DEEP_DUPLICATE_ALL) as ClassNode

# Debug method for printing the tree structure in the console. 
# You can ignore this.
func get_printable_data() -> String:
	return ""

## Handles the way in which the [TreeItem] should be built.[br][br]
##
## Each item has two columns available. It is recommended that the first
## column (0) shows the type of node and that the second (1) shows any 
## additional data or input fields that you want to expose to the user.
func _setup_editor_tree_item(item: TreeItem) -> void:
	pass

## Handles the way in which the node should react after an input field is
## updated from the editor.[br][br]
##
## If you haven't defined an editable field in any of the item's columns, you
## don't need to define this method.[br][br]
## 
## If you have defined an editable column, here is where you should parse its
## contents and update the value of the node's variables.
func _on_value_updated_from_editor(item: TreeItem) -> void:
	pass

## Deletes the node from the class tree.[br][br]
## 
## This method actually signals to its parent and widget that it should be 
## deleted so they can handle it appropriately and mantain the structure of
## the tree.
func delete() -> void:
	deleted.emit()

## Returns the scene corresponding to the node's widget.
@abstract
func get_widget() -> PackedScene;
