class_name ResourcesClassMobile
extends Node

# This file is used to manage the resources class in the editor.
# For example, to parse .dcc file to a ClassIndex, to add new entities, etc.

@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")
@onready var _bus: MobileEventBus = Engine.get_singleton(&"MobileSignals")

@export var class_index: ClassIndex

# Dictionary that contains the entities of the class.
var entities: Dictionary

# The root of the tree structure of the class. The node is a ClassNode, it means the resource.
var root_tree_structure: ClassNode

# The root node of the controllers
@onready var root_node_controller: Node = %Controllers

# The audio_widgets node, used to add to the scene the audio_widgets.
@onready var audio_widgets: Node2D = %AudioWidgets

# The current node of the class, used to know the current node in the reproduction.
var _current_node: ClassNode


func _ready():
	_bus_core.current_node_changed.connect(_current_node_changed)
	#_bus.add_class_leaf_entity.connect(_add_class_leaf_entity)
	_bus.add_class_leaf.connect(_add_class_leaf)
	_bus.add_class_group.connect(_add_class_group)
	#_bus.paste_class_nodes.connect(_paste_class_nodes)
	_bus.delete_class_nodes.connect(_delete_class_nodes)
	#_bus.make_group.connect(_make_group)
	NodeController.root_node_controller = root_node_controller
	NodeController.audio_widgets = audio_widgets


	#if !_parse():
		#push_error("Error parsing file: " + PersistenceMobile.class_path)
		#return
	if !_instantiate():
		push_error("Error instantiating class: " + class_index.name)
		return
	print("parse._ready")


func _instantiate() -> bool:
	entities = class_index.entities
	root_tree_structure = class_index.tree_structure
	root_tree_structure._setup_controller(true)
	_current_node = root_tree_structure
	return true

func _current_node_changed(current_node):
	_current_node = current_node


#region Resources Operations

#func _add_class_leaf_entity(entity: Entity, entity_properties) -> void:
	#class_index.entities_last_uid += 1
	#var entity_id: int = class_index.entities_last_uid
	#entity.entity_id = entity_id
	#entities[entity_id] = entity
	

	#var data_new = {
		#"type": "ClassLeaf",
		#"entity_id": entity_id,
		#"entity_properties": entity_properties
	#}
	#var class_node = ClassLeaf.deserialize(data_new)
	#class_node._setup_controller(true)
	

	#if _current_node is ClassGroup:
		#class_node.set_parent(_current_node)
		#var _current_class_group_childrens = _current_node._childrens
		#var index_current = _current_class_group_childrens.find(_current_node)
		#_current_class_group_childrens.insert(index_current + 1, class_node)
		#
#
	#if _current_node is ClassLeaf:
		#var parent_node = _current_node._parent
		#if parent_node is ClassGroup:
			#class_node.set_parent(parent_node)
			#var _current_class_group_childrens = parent_node._childrens
			#var index_current = _current_class_group_childrens.find(_current_node)
			#_current_class_group_childrens.insert(index_current + 1, class_node)
	#
	#_bus.update_treeindex.emit()
	#_bus_core.current_node_changed.emit(class_node)
	#_bus.seek_node.emit(class_node)


func _add_class_leaf(class_node: ClassNode) -> void:
	class_node._setup_controller(true)
	if _current_node is ClassGroup:
		class_node.set_parent(_current_node)
		var _current_class_group_childrens = _current_node._childrens
		var index_current = _current_class_group_childrens.find(_current_node)
		_current_class_group_childrens.insert(index_current + 1, class_node)

		
	if _current_node is ClassLeaf:
		var parent_node = _current_node._parent
		if parent_node is ClassGroup:
			class_node.set_parent(parent_node)
			var _current_class_group_childrens = parent_node._childrens
			var index_current = _current_class_group_childrens.find(_current_node)
			_current_class_group_childrens.insert(index_current + 1, class_node)

	_bus.update_treeindex.emit()
	_bus_core.current_node_changed.emit(class_node)
	_bus.seek_node.emit(class_node)


# Add a group after the current node. In case of being the current node being a group, it will follow the next logic:
# back -> indicates how the group is added. 
# If true, the group is added at the begin
# if false, the group is added at the end.
func _add_class_group(class_node: ClassNode, back: bool) -> void:
	class_node._setup_controller(true)
	if _current_node is ClassLeaf:
		var parent_node = _current_node._parent
		if parent_node is ClassGroup:
			class_node.set_parent(parent_node)
			var _current_class_group_childrens = parent_node._childrens
			var index_current = _current_class_group_childrens.find(_current_node)
			_current_class_group_childrens.insert(index_current + 1, class_node)

	if _current_node is ClassGroup:
		class_node.set_parent(_current_node)
		var _current_class_group_childrens = _current_node._childrens
		if back:
			var index_current = _current_class_group_childrens.find(_current_node)
			_current_class_group_childrens.insert(index_current + 1, class_node)
		else:
			var index_current = _current_class_group_childrens.size()
			_current_class_group_childrens.insert(index_current, class_node)
	
	_bus.update_treeindex.emit()
	_bus_core.current_node_changed.emit(class_node)

# Insert a class_node at the same level of the current node.
func _insert_class_group(class_node: ClassNode) -> void:
	class_node._setup_controller(true)
	if _current_node is ClassLeaf:
		var parent_node = _current_node._parent
		if parent_node is ClassGroup:
			class_node.set_parent(parent_node)
			var _current_class_group_childrens = parent_node._childrens
			var index_current = _current_class_group_childrens.find(_current_node)
			_current_class_group_childrens.insert(index_current + 1, class_node)

	if _current_node is ClassGroup:
		var _current_class_group_childrens
		if _current_node._parent == null: # We are at the root level.
			class_node.set_parent(root_tree_structure)
			_current_class_group_childrens = _current_node._childrens
		else:
			class_node.set_parent(_current_node._parent)
			_current_class_group_childrens = _current_node._parent._childrens

		var index_current = _current_class_group_childrens.find(_current_node)
		_current_class_group_childrens.insert(index_current + 1, class_node)

	
	_bus.update_treeindex.emit()
	_bus_core.current_node_changed.emit(class_node)


#func _paste_class_nodes() -> void:
	##var nodes_paste: Array[ClassNode] = PersistenceMobile.clipboard
	#
	#var node_group_parent: ClassNode = _current_node
#
	#for node in nodes_paste:
		#if node is ClassLeaf:
			#class_index.entities_last_uid += 1
			#var entity_id: int = class_index.entities_last_uid
			#node.entity_id = entity_id
			#node.entity.entity_id = entity_id
			#node.entity.tmp_to_persistent()
			#entities[entity_id] = node.entity
#
			#node._node_controller._add_child_root()
#
			#if _current_node is ClassGroup:
				#node.set_parent(_current_node)
				#var _current_class_group_childrens = _current_node._childrens
				#var index_current = _current_class_group_childrens.find(_current_node)
				#_current_class_group_childrens.insert(index_current + 1, node)
#
#
			#if _current_node is ClassLeaf:
				#var parent_node = _current_node._parent
				#if parent_node is ClassGroup:
					#node.set_parent(parent_node)
					#var _current_class_group_childrens = parent_node._childrens
					#var index_current = _current_class_group_childrens.find(_current_node)
					#_current_class_group_childrens.insert(index_current + 1, node)
#
			#_bus.update_treeindex.emit()
			#_bus_core.current_node_changed.emit(node)
			#_bus.seek_node.emit(node)
			#
		#elif node is ClassGroup:
			#if _current_node == node_group_parent:
				#_add_class_group(node, true)
			#elif _current_node._parent == node_group_parent:
				#_insert_class_group(node)
			#else:
				#_current_node = _current_node._parent
				#_insert_class_group(node)
#
#
	#PersistenceMobile.clipboard = []

# Delete nodes from the class structure/tree.
func _delete_class_nodes(nodes_del: Array[ClassNode]):
	var first: ClassNode = nodes_del[0]
	var parent_group: ClassGroup = first._parent
	
	# first_current is used to determine the previous node of the deleted nodes.
	var first_current = parent_group._node_controller.get_previous([parent_group._node_controller, first._node_controller])
	if first_current[0] == null: # We are at the root level.
		first_current[0] = root_tree_structure._node_controller


	for node in nodes_del:
		node.self_delete()
	_bus.update_treeindex.emit()
	_bus_core.current_node_changed.emit(first_current[0]._class_node)
	_bus.seek_node.emit(first_current[0]._class_node)


# Make a group from the selected nodes in the clipboard.
#func _make_group():
	## The first node in the clipboard is used to determine where the group will be created.
	#var first = PersistenceMobile.clipboard[0]
#
	## The parent group is to check if a new group is needed, because we only allow to create groups at the same level.
	#var parent_group: ClassGroup = first._parent
#
	#if parent_group == null:
		#push_error("Error: The clipboard does not contain a valid first node.")
		#return
	#
	## first_current is used to determine the previous node of the new group.
	#var first_current = parent_group._node_controller.get_previous([parent_group._node_controller, first._node_controller])
	#if first_current[0] == null: # We are at the root level.
		#first_current[0] = root_tree_structure._node_controller
#
	## Case: We are the first element in the parent group, so the previous is the parent of the parent group!
	#if first_current[0] == parent_group.get_parent_controller():
		#first_current[0] = parent_group._node_controller
#
	#var data_new = {
		#"name": "Group",
		#"type": "ClassGroup",
		#"childrens": []
	#}
	#var class_node = ClassGroup.deserialize(data_new)
	#PersistenceMobile.resources_class._current_node = first_current[0]._class_node
#
	#_bus.add_class_group.emit(class_node, true)
	#
	#for node in PersistenceMobile.clipboard:
		#if node in parent_group._childrens:
			#node._parent = class_node
			#parent_group._childrens.erase(node)
			#class_node.add_child(node)
#
	#_bus.update_treeindex.emit()
	#_bus_core.current_node_changed.emit(first_current[0]._class_node)
	#_bus.seek_node.emit(first_current[0]._class_node)

#endregion

#region Parse the class file.

# Parse the class file.
#func _parse() -> bool:
	#return _parse_keep_compressed()


# Parse the class file, but in the process keep the zip file compressed.
# This is intended to be used only for reproducing the class.
#var zip_file: ZIPReader
#func _parse_keep_compressed() -> bool:
	#var zip_path: String = PersistenceMobile.file_path
	#
	#zip_file = ZIPReader.new()
	#Widget.zip_file = zip_file
	#print("File: " + zip_path)
	#var err := zip_file.open(zip_path)
	#if err != OK:
		#push_error("Error %d opening file: " % err)
		#return false
	#if !zip_file.file_exists("index.json"):
		#push_error("Error: index.json not found in zip file")
		#return false
	#
	#var index_string := zip_file.read_file("index.json").get_string_from_utf8()
#
	#var index = JSON.parse_string(index_string)
	#if index == null or typeof(index) != TYPE_DICTIONARY:
		#return false
	#class_index = ClassIndex.deserialize(index)
#
	#return class_index != null


# Parse the class file, decompressing it to a temporary directory.
# This is intended to be used only for editing the class.
#func _parse_decompress_tmp():
	#var zip_path: String = PersistenceMobile.file_path
	#var dir_tmp: String = "user://tmp/class_editor/"
#
	#if decompress_zip(zip_path, dir_tmp):
		#print("Temporal Class Path: ", dir_tmp)
	#else:
		#push_error("Error %d opening file: " % zip_path)
		#return false
	#
	#var index_path: String = dir_tmp.path_join("index.json")
	#var file: FileAccess = FileAccess.open(index_path, FileAccess.READ)
	#
	#var index_string: String = file.get_as_text()
	#file.close()
	#
	#var index = JSON.parse_string(index_string)
	#if index == null or typeof(index) != TYPE_DICTIONARY:
		#return false
	#class_index = ClassIndex.deserialize(index)
	#Widget.dir_class = "user://tmp/class_editor/"
	#return class_index != null
#

# Decompress a zip file to a temporary directory.
func decompress_zip(__zip_path: String, __dir_tmp: String) -> bool:
	var reader: ZIPReader = ZIPReader.new()
	var err = reader.open(__zip_path)
	if err != OK:
		return false

	if not __dir_tmp.ends_with("/"):
		__dir_tmp += "/"

	if DirAccess.dir_exists_absolute(__dir_tmp):
		_remove_dir_recursively(__dir_tmp)

	DirAccess.make_dir_recursive_absolute(__dir_tmp)

	for internal_path in reader.get_files():
		var absolute_path := __dir_tmp + internal_path
		if internal_path.ends_with("/"):
			DirAccess.make_dir_recursive_absolute(absolute_path)
			continue

		DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())

		var file := FileAccess.open(absolute_path, FileAccess.WRITE)
		if not file:
			reader.close()
			return false
		file.store_buffer(reader.read_file(internal_path))
		file.close()

	reader.close()
	return true

# Remove a directory and all its contents recursively.
# This function is used to clean up temporary directories created during the parsing process.
func _remove_dir_recursively(path_del: String) -> void:
	for sub_dir in DirAccess.get_directories_at(path_del):
		_remove_dir_recursively(path_del.path_join(sub_dir) + "/")

	for file_name in DirAccess.get_files_at(path_del):
		DirAccess.remove_absolute(path_del.path_join(file_name))

	DirAccess.remove_absolute(path_del)

#endregion
