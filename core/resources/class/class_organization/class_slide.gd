# 1. class name: fill the class name
class_name ClassSlide
extends ClassGroup

# 2. docs: use docstring (##) to generate docs for this file

# 3. signals: define signals here
# signal layer_added(layer: ClassNode, index: int)
# signal layer_removed(layer: ClassNode, index: int)
# signal layer_visibility_changed(layer: ClassNode, visible: bool)

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here
#@export var _depth: int = 1
#@export var _order: int = 0

# 7. public variables: define all public variables here


# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here

# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here

func add_child(child: ClassNode, index: int = -1):
	if index >= 0:
		children.insert(index, child)
	else:
		children.append(child)
	child_added.emit(child, index)


func get_class_name() -> String:
	return "ClassSlide"


func get_editor_name() -> String:
	return _name


#func serialize() -> Dictionary:
	#return {
		#"name": _name,
		#"type": get_class_name(),
		#"childrens": _childrens.map(func(l): return l.serialize()),
		#"depth": _depth,
		#"order": _order,
	#}


#static func deserialize(data: Dictionary) -> ClassSlide:
	#var instance: ClassSlide = ClassSlide.new()
	#instance._name = data["name"]
	#for child_data in data["childrens"]:
		#var child = ClassNode.deserialize(child_data)
		#child.set_parent(instance)
		#instance.add_child(child)
	#return instance


# Setup the controller associated with this classnode.
#func _setup_controller(is_child_root: bool) -> void:
	#var _class: String = get_class_name().replace("Class", "") + "Controller"
	#assert(CustomClassDB.class_exists(_class), "Class " + _class + " does not exist.")
	#var controller: SlideController = CustomClassDB.instantiate(_class)
	#
	#for child in _childrens:
		#child._setup_controller(is_child_root)
#
	#_node_controller = controller
	#controller._setup(self)
	#if is_child_root:
		#controller._add_child_root()
#

# Delete this classnode and all its children.
#func self_delete() -> void:
	#var children_copy = _childrens.duplicate()
	#
	#for child in children_copy:
		#child.self_delete()
#
	#if _parent == null:
		#return
	#
	#_parent.child_delete(self)
	#_node_controller.self_delete()

# Delete a child from this classnode.
#func child_delete(child: ClassNode) -> void:
	#if child in _childrens:
		#_childrens.erase(child)

func _setup_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, "Slide:")
	item.set_text(1, _name)
	item.set_editable(1, true)

func get_printable_data() -> String:
	return "Slide: %s" % _name

func update_value(item: TreeItem) -> void:
	var new_name := item.get_text(1)
	_name = new_name

func get_widget() -> PackedScene:
	return preload("uid://c2gmvcijrse7y")

# 13. private methods: define all private methods here, use _ as preffix
#func _validate():
	#pass

func _to_string() -> String:
	return "Slide: %s" % _name

# 14. subclasses: define all subclasses here
