class_name ControlPanelMobile
extends MarginContainer

#@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")
#@onready var _bus: MobileEventBus = Engine.get_singleton(&"MobileSignals")

signal audio_record(active: bool)
signal request_detach

@onready var menu_btn_edit: MenuButton = %EditMenuButton
@onready var menu_btn_insert: MenuButton = %InsertMenuButton

@onready var btn_audio: CheckButton = %AudioButton
@onready var btn_pen: CheckButton = %PenButton


@onready var tree_manager: TreeManagerMobile = %IndexTree

var resources_class: ResourcesClassMobile

var _current_node: ClassNode
var _class_index: ClassIndex
var current_item_tree: TreeItem
var select_item_index_disabled: bool = false

func _ready() -> void:
	#_bus_core.current_node_changed.connect(_current_node_changed)
	#_bus.update_treeindex.connect(_setup_index_class)

	menu_btn_edit.get_popup().id_pressed.connect(_on_menu_btn_edit)
	#_bus.disabled_toggle_edit_button.connect(_disabled_toggle_edit_button)
	
	menu_btn_insert.get_popup().id_pressed.connect(_on_menu_btn_insert)
	#_bus.disabled_toggle_insert_button.connect(_disabled_toggle_insert_button)

	btn_audio.toggled.connect(_on_toggle_audio_pressed)
	#_bus.disabled_toggle_audio_button.connect(_disabled_toggle_audio_button)
	#btn_pen.toggled.connect(_on_button_pen_toggled)
	#_bus.disabled_toggle_pen_button.connect(_disabled_toggle_pen_button)

	tree_manager.item_activated.connect(_on_item_activated)
	#_bus.disabled_toggle_select_item_index.connect(_disabled_toggle_select_item_index)


# Setup the control panel with the current resources class
func _setup():
	#resources_class = PersistenceMobile.resources_class
	_setup_index_class()
	_current_node_changed(resources_class._current_node)


#region Menu Edit

func _on_menu_btn_edit(id: int) -> void:
	if id == 1:
		_copy_to_clipboard()
	if id == 2:
		_cut_to_clipboard()
	#if id == 3:
		#_paste()
	if id == 4:
		_delete()

func _disabled_toggle_edit_button(active: bool) -> void:
	menu_btn_edit.disabled = active

func _copy_to_clipboard() -> void:
	var first = tree_manager.get_next_selected(null)

	if first == null:
		return
	
	var nodes_copy: Array[ClassNode] = []
	var current = first
	
	while current:
		nodes_copy.append(current.get_metadata(0))
		current = tree_manager.get_next_selected(current)
	
	#PersistenceMobile.clipboard.clear()
	#PersistenceMobile.clipboard_clear_files()

	for node in nodes_copy:
		if node is ClassLeaf:
			var node_copy: ClassNode = node.copy_tmp()
			node_copy._setup_controller(false)
			#PersistenceMobile.clipboard.append(node_copy)

		
		#elif node is ClassGroup:
			#var data_new = {
				#"name": "Group",
				#"type": "ClassGroup",
				#"childrens": []
			#}
			#var new_node = ClassGroup.deserialize(data_new)
			#PersistenceMobile.clipboard.append(new_node)

func _cut_to_clipboard() -> void:
	_copy_to_clipboard()
	_delete()

#func _paste() -> void:
	#var first = tree_manager.get_next_selected(null)
	#if first != null:
		#PersistenceMobile.resources_class._current_node = first.get_metadata(0)
	#_bus.paste_class_nodes.emit()


func _delete() -> void:
	var first = tree_manager.get_next_selected(null)
	if first == null:
		return
	var nodes_del: Array[ClassNode] = []
	var current = first
	
	while current:
		nodes_del.append(current.get_metadata(0))
		current = tree_manager.get_next_selected(current)
	
	#_bus.delete_class_nodes.emit(nodes_del)

	
#endregion


#region Menu Insert

# Handle the insert menu button actions
func _on_menu_btn_insert(id: int) -> void:
	#if id == 1:
		#_add_group()
	#if id == 2:
		#_push_group()
	if id == 3:
		_make_group()
	#if id == 4:
		#_add_clear()
	#if id == 5:
		#_add_pause()

func _disabled_toggle_insert_button(active: bool) -> void:
	menu_btn_insert.disabled = active

# Add a new group at the beginning of the current node
#func _add_group() -> void:
	#var data_new = {
		#"name": "Group",
		#"type": "ClassGroup",
		#"childrens": []
	#}
	#var class_node = ClassGroup.deserialize(data_new)
	#var first = tree_manager.get_next_selected(null)
	#if first != null:
		#PersistenceMobile.resources_class._current_node = first.get_metadata(0)
	#_bus.add_class_group.emit(class_node, true)

# Push a new group to the end of the current node
#func _push_group() -> void:
	#var data_new = {
		#"name": "Group",
		#"type": "ClassGroup",
		#"childrens": []
	#}
	#var class_node = ClassGroup.deserialize(data_new)
	#var first = tree_manager.get_next_selected(null)
	#if first != null:
		#PersistenceMobile.resources_class._current_node = first.get_metadata(0)
	#_bus.add_class_group.emit(class_node, false)

func _make_group() -> void:
	var first = tree_manager.get_next_selected(null)

	if first == null:
		return
	
	var nodes_to_group: Array[ClassNode] = []
	var current = first
	
	while current:
		nodes_to_group.append(current.get_metadata(0))
		current = tree_manager.get_next_selected(current)
	
	#PersistenceMobile.clipboard.clear()
	#PersistenceMobile.clipboard_clear_files()

	#for node in nodes_to_group:
		#PersistenceMobile.clipboard.append(node)
	#_bus.make_group.emit()


# Add a clear entity after the current node
#func _add_clear() -> void:
	#var entity_clear = ClearEntity.new()
	#var data_new = {
		#"type": "ClassLeaf",
		#"entity_id": entity_clear.entity_id,
		#"entity_properties": []
	#}
	#var class_node = ClassLeaf.deserialize(data_new)
	#var first = tree_manager.get_next_selected(null)
	#if first != null:
		#PersistenceMobile.resources_class._current_node = first.get_metadata(0)
	#_bus.add_class_leaf.emit(class_node)

#func _add_pause() -> void:
	#var entity_pause = PausePlaybackEntity.new()
	#var data_new = {
		#"type": "ClassLeaf",
		#"entity_id": entity_pause.entity_id,
		#"entity_properties": []
	#}
	#var class_node = ClassLeaf.deserialize(data_new)
	#var first = tree_manager.get_next_selected(null)
	#if first != null:
		#PersistenceMobile.resources_class._current_node = first.get_metadata(0)
	#_bus.add_class_leaf.emit(class_node)
#endregion


#region Whiteboard Interactions

# Toggle audio recording
func _on_toggle_audio_pressed(active: bool) -> void:
	audio_record.emit(active)
	#if active:
		#PersistenceMobile._epilog(PersistenceMobile.Status.RECORDING_AUDIO)
	#else:
		#PersistenceMobile._epilog(PersistenceMobile.Status.STOPPED)

func _disabled_toggle_audio_button(active: bool) -> void:
	btn_audio.disabled = active

# Toggle pen mode
#func _on_button_pen_toggled(active: bool) -> void:
	#_bus.pen_toggled.emit(active)
	#if active:
		#PersistenceMobile._epilog(PersistenceMobile.Status.RECORDING_PEN)
	#else:
		#PersistenceMobile._epilog(PersistenceMobile.Status.STOPPED)

func _disabled_toggle_pen_button(active: bool) -> void:
	btn_pen.disabled = active

# Request to detach the whiteboard
func _on_button_detach_pressed() -> void:
	request_detach.emit()

#endregion


#region Tree Index

# Setup the index class and build the tree structure
func _setup_index_class():
	_class_index = resources_class.class_index
	var entities = _class_index.entities
	var root_tree_structure = _class_index.tree_structure
	
	tree_manager.tree_manager_index = tree_manager
	tree_manager.build(root_tree_structure, entities)

# Select an item in the tree and update the current node
func _on_item_activated() -> void:
	if select_item_index_disabled:
		return
	#var item = tree_manager.get_selected()
	#var node = item.get_metadata(0)
	#_bus_core.current_node_changed.emit(node)
	#_bus.seek_node.emit(node)

func _disabled_toggle_select_item_index(active: bool) -> void:
	select_item_index_disabled = active

# Update the current node
func _current_node_changed(current_node):
	
	if current_item_tree != null:
		current_item_tree.set_custom_color(0, Color.GRAY)
	current_item_tree = tree_manager.find_item_by_node(current_node)
	tree_manager.scroll_to_item(current_item_tree, true)
	current_item_tree.set_custom_color(0, Color.LIME_GREEN)
	_current_node = current_node

#endregion
