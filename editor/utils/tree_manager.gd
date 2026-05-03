class_name TreeManagerEditor
extends Tree


signal updated
signal node_added(node: ClassNode, parent: ClassGroup, index: int)
signal tree_modified
signal node_selected(node: ClassNode)

var tree_manager_index: Tree
var clipboard: Array[TreeItem] = []
var _current_item: TreeItem

func _ready() -> void:
	set_column_custom_minimum_width(0, 200)
	set_column_expand_ratio(0, 1)
	set_column_expand_ratio(1, 3)
	set_column_expand(0, false)
	set_column_expand(1, true)

func build(root_node: ClassRoot) -> void:
	clear()
	_build_node(root_node)
	WhiteboardManager.reprocess_tree()

func _build_node(node: ClassNode, parent: TreeItem = null) -> void:
	var item := create_item(parent)
	node.config_editor_tree_item(item)
	if node.is_leaf(): return
	for child in (node as ClassGroup).children:
		_build_node(child, item)

func add_node(node: ClassNode, nest := true) -> TreeItem:
	var new_item: TreeItem 
	var selected := get_next_selected(null)
	if not selected:
		selected = get_root()
	var selected_node := selected.get_metadata(0) as ClassNode
	var parent := selected.get_parent()
	if selected_node.is_leaf() or not nest:
		new_item = create_item(parent)
		new_item.move_after(selected)
	else:
		parent = selected
		new_item = create_item(selected)
	node.config_editor_tree_item(new_item)
	if nest:
		deselect_all()
		new_item.select(0)
	#updated.emit()
	var parent_node := parent.get_metadata(0) as ClassNode
	var index := new_item.get_index()
	node_added.emit(node, parent_node, index)
	set_current_item(new_item)
	return new_item

func rectify_class_tree() -> void:
	_rectify_class_node(get_root())
	print(get_root().get_metadata(0))
	#build(EditorManager.root)

func _rectify_class_node(item: TreeItem) -> void:
	var node := item.get_metadata(0) as ClassNode
	# Leaf nodes either update themselves in real time or are not editable
	# We don't need to do anything else to them
	if node.is_leaf():
		return
	var group := node as ClassGroup
	group.clear_children()
	for child in item.get_children():
		_rectify_class_node(child)
		var child_node := child.get_metadata(0) as ClassNode
		group.add_child(child_node)

func _on_node_added(node: ClassNode, parent: ClassGroup, index: int) -> void:
	parent.add_child(node, index)
	var widget := WhiteboardManager.get_root_widget().search_widget_by_class_node(node)
	WhiteboardManager.get_root_widget().jump_to_widget(widget)

func _group_selected(item: TreeItem) -> void:
	var selected := get_next_selected(null)
	while selected:
		var parent := selected.get_parent()
		parent.remove_child(selected)
		item.add_child(selected)
		selected = get_next_selected(selected)
	deselect_all()
	item.select(0)
	updated.emit()

func make_group() -> void:
	var item := add_node(ClassGroup.new(), false)
	_group_selected(item)

func make_slide() -> void:
	var item := add_node(ClassSlide.new(), false)
	_group_selected(item)

## Reset the colors of all items in the tree to a default color.
func reset_colors():
	var item = get_root()
	while item:
		item.set_custom_color(0, Color.GRAY)
		item = item.get_next_visible()

# Find a TreeItem by its associated ClassNode.
func find_item_by_node(target: ClassNode) -> TreeItem:
	return _find_in_children(get_root(), target)

func _find_in_children(item: TreeItem, target: ClassNode) -> TreeItem:
	var node := item.get_metadata(0) as ClassNode
	if node == target:
		return item
	for child in item.get_children():
		var found_item := _find_in_children(child, target)
		if found_item:
			return found_item
	return null

func get_class_tree() -> ClassRoot:
	return get_root().get_metadata(0) as ClassRoot

#region Drag&Drop

func _get_drag_data(at_position: Vector2) -> Variant:
	drop_mode_flags = DropModeFlags.DROP_MODE_INBETWEEN | DropModeFlags.DROP_MODE_ON_ITEM
	var item := get_item_at_position(at_position)
	if not item: return null
	# TODO: Replace D&D icon
	var icon := TextureRect.new()
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	icon.scale = Vector2(0.05, 0.05)
	icon.texture = preload("uid://dsgbxa6x62b5m")
	set_drag_preview(icon)
	return item

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	var item := get_item_at_position(at_position)
	# Prevent item from dropping in an empty space
	if not item: return false
	# Prevent item from becoming a child of itself
	var dropped_item := data as TreeItem
	var parent := item
	while parent.get_parent() != parent.get_tree().get_root():
		if parent.get_parent() == dropped_item:
			return false
		parent = parent.get_parent()
	# Allow adding children only if the target item is not a leaf node
	var node := item.get_metadata(0) as ClassNode
	var drop_section := get_drop_section_at_position(at_position)
	if drop_section == 0 and node.is_leaf():
		var leaf := node as ClassLeaf
		# NodeReferenceEntity is a special case and can accept dropping items
		if leaf.entity is not NodeReferenceEntity:
			return false
		var reference_entity := leaf.entity as NodeReferenceEntity
		var dropped_node := dropped_item.get_metadata(0) as ClassNode
		return reference_entity._is_node_valid(dropped_node)
	return not node.is_leaf() or drop_section != 0

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var item := get_item_at_position(at_position)
	var dropped_item := data as TreeItem
	if not item or not dropped_item or item == dropped_item:
		return
	var item_parent := item.get_parent()
	var dropped_parent := dropped_item.get_parent()
	var drop_section := get_drop_section_at_position(at_position)
	
	# Special case for NodeReferences, this sets the reference instead
	# of moving the node
	var node := item.get_metadata(0) as ClassNode
	if drop_section == 0 and node.is_leaf() and \
			(node as ClassLeaf).entity is NodeReferenceEntity:
		var entity := (node as ClassLeaf).entity as NodeReferenceEntity
		var dropped_node := dropped_item.get_metadata(0) as ClassNode
		if entity._is_node_valid(dropped_node):
			entity.set_reference(dropped_node)
		return
	
	# Determines wether to drop the dragged item before, after or as a
	# child of the target item.
	dropped_parent.remove_child(dropped_item)
	if drop_section == 0:
		item.add_child(dropped_item)
	elif drop_section == -1:
		item_parent.add_child(dropped_item)
		dropped_item.move_before(item)
	else:
		item_parent.add_child(dropped_item)
		dropped_item.move_after(item)
	updated.emit()
	print(get_root().get_metadata(0))

#endregion

#region Copy/Paste

func _clear_clipboard() -> void:
	clipboard.clear()

func _deselect_children() -> void:
	var selected := get_next_selected(null)
	while selected:
		for child in selected.get_children():
			child.deselect(0)
		selected = get_next_selected(selected)

func _cut() -> void:
	_clear_clipboard()
	_deselect_children()
	var selected := get_next_selected(null)
	while selected:
		var next_selected = get_next_selected(selected)
		clipboard.append(selected)
		var parent := selected.get_parent()
		parent.remove_child(selected)
		selected = next_selected
	updated.emit()

func _copy() -> void:
	_clear_clipboard()
	_deselect_children()
	var selected := get_next_selected(null)
	while selected:
		var duplicated_item = _copy_item(selected, null)
		clipboard.append(duplicated_item)
		var parent := duplicated_item.get_parent()
		parent.remove_child(duplicated_item)
		selected = get_next_selected(selected)

func _copy_item(item: TreeItem, parent: TreeItem = null) -> TreeItem:
	var duplicated_item = create_item(parent)
	var node := item.get_metadata(0) as ClassNode
	var duplicated_node := node.copy()
	if not node.is_leaf():
		(node as ClassGroup).clear_children()
	duplicated_item.set_metadata(0, duplicated_node)
	duplicated_node.config_editor_tree_item(duplicated_item)
	for child in item.get_children():
		_copy_item(child, duplicated_item)
	return duplicated_item

func _paste() -> void:
	var selected := get_next_selected(null)
	if not selected:
		selected = get_root()
	var node := selected.get_metadata(0) as ClassNode
	var parent := selected.get_parent()
	for item in clipboard:
		if node.is_leaf():
			var copied := _copy_item(item, parent)
			copied.move_after(selected)
		else:
			_copy_item(item, selected)
	updated.emit()

func _delete() -> void:
	_deselect_children()
	var selected := get_next_selected(null)
	while selected:
		var node := selected.get_metadata(0) as ClassNode
		node.delete()
		var parent := selected.get_parent()
		parent.remove_child(selected)
		selected.free()
	updated.emit()

#endregion

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cut"):
		_cut()
	elif event.is_action_pressed("copy"):
		_copy()
	elif event.is_action_pressed("paste"):
		_paste()
	elif event.is_action_pressed("delete"):
		_delete()
	elif event.is_action_pressed("make_group"):
		make_group()
	elif event.is_action_pressed("make_slide"):
		make_slide()

func _on_nothing_selected() -> void:
	deselect_all()

func _on_multi_selected(item: TreeItem, column: int, selected: bool) -> void:
	if Input.is_action_pressed("multi_select"):
		if selected:
			item.select(column)
		else:
			item.deselect(column)
	elif selected:
		deselect_all()
		item.select(column)
	else:
		deselect_all()

func _on_item_edited() -> void:
	var item := get_selected()
	var node := item.get_metadata(0) as ClassNode
	node.update_value(item)
	print(node.get_printable_data())

func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	prints((item.get_metadata(0) as ClassNode).get_printable_data(), column, id, mouse_button_index)

func _on_item_activated() -> void:
	reset_colors()
	var item := get_next_selected(null)
	item.set_custom_color(0, Color.GREEN)
	node_selected.emit(item.get_metadata(0) as ClassNode)

func set_current_item(item: TreeItem) -> void:
	print("setting current item")
	reset_colors()
	_current_item = item
	_current_item.set_custom_color(0, Color.GREEN)
	#node_selected.
