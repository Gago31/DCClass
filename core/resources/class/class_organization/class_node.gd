# 1. class name: fill the class name
@abstract
class_name ClassNode
extends Resource

# 2. docs: use docstring (##) to generate docs for this file

# 3. signals: define signals here
signal updated
signal deleted

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here

## Reference to the parent node of this node in the tree.
var _parent: ClassNode


# 7. public variables: define all public variables here


# 8. private variables: define all private variables here, use _ as preffix
## Reference to the node controller that manages this node.
var _node_controller: NodeController

# 9. onready variables: define all onready variables here

# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here

# Get the controller associated with this ClassNode.
func get_parent_controller():
	if _parent != null:
		return _parent._node_controller
	return null

# Set the parent of this ClassNode.
func set_parent(parent):
	_parent = parent

func get_class_name() -> String:
	return "ClassNode"

func get_editor_name() -> String:
	return "Class_Node"

func is_leaf() -> bool:
	return false

func config_editor_tree_item(item: TreeItem) -> void:
	_setup_editor_tree_item(item)
	item.set_metadata(0, self)

func get_printable_data() -> String:
	return ""

func update_value(item: TreeItem) -> void:
	_on_value_updated_from_editor(item)
	updated.emit()

func _setup_editor_tree_item(item: TreeItem) -> void:
	pass

func _on_value_updated_from_editor(item: TreeItem) -> void:
	pass

func rebuild(parent_item: ClassNode, children: Array[ClassNode]) -> void:
	pass

func copy() -> ClassNode:
	return duplicate_deep(Resource.DEEP_DUPLICATE_INTERNAL)

func delete() -> void:
	deleted.emit()

# Serialize to a dictionary format(.json) for saving.
#func serialize() -> Dictionary:
	#return {
		#"type": get_class_name()
	#}

# Deserialize from a dictionary format(.json) to resource(ClassNode).
#static func deserialize(data: Dictionary) -> ClassNode:
	#var instance: ClassNode = CustomClassDB.instantiate(data["type"]).deserialize(data)
	#return instance


# 13. private methods: define all private methods here, use _ as preffix
func _validate():
	pass

## Returns the scene corresponding to the node's widget.
@abstract
func get_widget() -> PackedScene;

# 14. subclasses: define all subclasses here
