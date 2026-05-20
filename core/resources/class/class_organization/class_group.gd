class_name ClassGroup
extends ClassNode


## Inner node of the class tree. Contains an array of children [ClassNode]s
## that are played sequentially. Also has a name that will be displayed in
## the Player as the name of that section of the class.


## A child was added to the group at a specific index. Used in the editor.
signal child_added(child: ClassNode, index: int)
## A child was deleted from the group. Used in the editor.
signal child_deleted(child: ClassNode)
## All children were deleted from the group. Used in the editor.
signal children_cleared


## The name of the group in the class. Will be visible in the Player.
@export var _name: String
## The nodes inside this group. They can be other groups or [ClassLeaf]s.
@export var children: Array[ClassNode] = []


## Adds a child node to the group. If [code]index[/code] is positive or 0,
## inserts the child at that index, otherwise it is added at the end.
func add_child(child: ClassNode, index: int = -1):
	if index >= 0:
		children.insert(index, child)
	else:
		children.append(child)
	if not child.deleted.is_connected(_on_child_deleted):
		child.deleted.connect(_on_child_deleted.bind(child))
	child_added.emit(child, index)

## Removes all children from the group.
func clear_children() -> void:
	children.clear()
	children_cleared.emit()

func get_class_name():
	return "ClassGroup"

func get_editor_name():
	return _name

func get_printable_data() -> String:
	return "Group: %s" % _name

func get_widget() -> PackedScene:
	return preload("uid://bghrrlga67xx4")

func _setup_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, "Group:")
	item.set_text(1, _name)
	item.set_editable(1, true)

func _on_value_updated_from_editor(item: TreeItem) -> void:
	var new_name := item.get_text(1)
	_name = new_name

## Debug method for printing the node's children in the console.
func _children_to_str(nesting: int) -> String:
	var s := ""
	for child in children:
		s += "-".repeat(nesting) + " " + str(child) + "\n"
		if not child.is_leaf():
			s += (child as ClassGroup)._children_to_str(nesting + 1)
	return s

func _to_string() -> String:
	return "Group: %s" % _name

func _on_child_deleted(child: ClassNode) -> void:
	children.erase(child)
	child_deleted.emit(child)
