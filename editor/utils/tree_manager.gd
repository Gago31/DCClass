class_name TreeManagerEditor
extends Tree


signal updated
signal node_added(node: ClassNode, parent: ClassGroup, index: int)
signal tree_modified
signal node_selected(node: ClassNode)

@export var drag_icon: PackedScene

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
	_on_multi_selected(get_root(), 0, true)

func _build_node(node: ClassNode, parent: TreeItem = null) -> void:
	var item := create_item(parent)
	node.config_editor_tree_item(item)
	if node.is_leaf(): return
	for child in (node as ClassGroup).children:
		_build_node(child, item)

func add_node(node: ClassNode, nest := true, select := true) -> TreeItem:
	var new_item: TreeItem 
	var selected := get_next_selected(null)
	if not selected:
		selected = get_root()
	var selected_node := selected.get_metadata(0) as ClassNode
	var parent := selected.get_parent()
	if selected_node.is_leaf() or not nest or (selected.collapsed and selected.get_child_count() != 0):
		new_item = create_item(parent)
		new_item.move_after(selected)
	else:
		parent = selected
		new_item = create_item(selected)
		new_item.move_before(parent.get_child(0))
	node.config_editor_tree_item(new_item)
	if nest:
		deselect_all()
		_select_item(new_item)
	#updated.emit()
	var parent_node := parent.get_metadata(0) as ClassNode
	var index := new_item.get_index()
	parent_node.add_child(node, index)
	if select:
		node_added.emit(node, parent_node, index)
		set_current_item(new_item)
	scroll_to_item(new_item, true)
	return new_item

func rectify_class_tree() -> void:
	_rectify_class_node(get_root())
	WhiteboardManager.reprocess_tree()
	tree_modified.emit()
	#print(get_root().get_metadata(0))
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
		#var index := child.get_index()
		group.add_child(child_node)

func _select_item(item: TreeItem) -> void:
	item.select(0)
	item.select(1)

func _deselect_item(item: TreeItem) -> void:
	item.deselect(0)
	item.deselect(1)

func _on_node_added(node: ClassNode, parent: ClassGroup, index: int) -> void:
	#parent.add_child(node, index)
	updated.emit()
	var root_widget := WhiteboardManager.get_root_widget()
	if not root_widget: return
	var widget := root_widget.search_widget_by_class_node(node)
	WhiteboardManager.get_root_widget().jump_to_widget(widget)

func _group_selected(item: TreeItem) -> void:
	_deselect_children()
	var selected := get_next_selected(null)
	while selected:
		var parent := selected.get_parent()
		var next := get_next_selected(selected)
		parent.remove_child(selected)
		item.add_child(selected)
		_deselect_item(selected)
		selected = next
	deselect_all()
	item.collapsed = true
	_on_multi_selected(item, 0, true)
	updated.emit()

func make_group() -> void:
	var item := add_node(ClassGroup.new(), false, false)
	_group_selected(item)

func make_slide() -> void:
	var item := add_node(ClassSlide.new(), false, false)
	_group_selected(item)

## Reset the colors of all items in the tree to a default color.
func reset_colors():
	var item = get_root()
	while item:
		item.set_custom_color(0, Color.GRAY)
		item = item.get_next_visible()

# Find a TreeItem by its associated ClassNode.
func find_item_by_node(target: ClassNode) -> TreeItem:
	if not target:
		return get_root()
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
	var items: Array[TreeItem] = []
	var selected := get_next_selected(null)
	while selected:
		items.append(selected)
		selected = get_next_selected(selected)
	#var item := get_item_at_position(at_position)
	#if not item: return null
	#prints("Dragging", item, "selected:", item.is_selected(0) or item.is_selected(1))
	var icon := drag_icon.instantiate() as Control
	set_drag_preview(icon)
	#return [item]
	return items

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	var item := get_item_at_position(at_position)
	# Prevent item from dropping in an empty space
	if not item: return false
	# Prevent item from becoming a child of itself
	#var dropped_item := data as TreeItem
	#var can_drop := true
	for dropped_item in data as Array[TreeItem]:
		if dropped_item == get_root():
			return false
		var parent := item
		while parent != parent.get_tree().get_root():
			if parent == dropped_item:
				return false
			parent = parent.get_parent()
		#while parent.get_parent() != parent.get_tree().get_root():
			#if parent.get_parent() == dropped_item:
				#return false
			#parent = parent.get_parent()
		# Allow adding children only if the target item is not a leaf node
		var node := item.get_metadata(0) as ClassNode
		var drop_section := get_drop_section_at_position(at_position)
		if drop_section == 0 and node.is_leaf():
			var leaf := node as ClassLeaf
			# NodeReferenceEntity is a special case and can accept dropping items
			if leaf.entity is not NodeReferenceEntity:
				return false
			if (data as Array[TreeItem]).size() != 1:
				return false
			var reference_entity := leaf.entity as NodeReferenceEntity
			var dropped_node := dropped_item.get_metadata(0) as ClassNode
			return reference_entity._is_node_valid(dropped_node)
		return not node.is_leaf() or drop_section != 0
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var item := get_item_at_position(at_position)
	#var dropped_item := data as TreeItem
	var insert_position := item
	for dropped_item in data as Array[TreeItem]:
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
			dropped_item.move_after(insert_position)
			insert_position = dropped_item
	updated.emit()
	#print(get_root().get_metadata(0))

#endregion

#region Copy/Paste

func _clear_clipboard() -> void:
	clipboard.clear()

func _deselect_children() -> void:
	var selected := get_next_selected(null)
	while selected:
		if selected == get_root():
			selected = get_next_selected(selected)
			continue
		if selected.get_parent().is_selected(0):
			var next := get_next_selected(selected)
			_deselect_item(selected)
			selected = next
		else:
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
	var duplicated_item := create_item(parent)
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
	var last_added := selected
	for item in clipboard:
		if node.is_leaf():
			var copied := _copy_item(item, parent)
			copied.move_after(last_added)
			last_added = copied
		else:
			_copy_item(item, selected)
	updated.emit()

func _delete() -> void:
	_deselect_children()
	var selected := get_next_selected(null)
	var prev := selected.get_prev_in_tree()
	var prev_node: ClassNode
	if prev:
		prev_node = prev.get_metadata(0) as ClassNode
	#node_selected.emit(prev.get_metadata(0) as ClassNode)
	while selected:
		var next_selected := get_next_selected(selected)
		var node := selected.get_metadata(0) as ClassNode
		node.delete()
		var parent := selected.get_parent()
		parent.remove_child(selected)
		selected.free()
		selected = next_selected
	var new_prev := find_item_by_node(prev_node)
	WhiteboardManager.reset_context()
	set_current_item(new_prev)
	#prev.select(0)
	await get_tree().process_frame
	updated.emit()
	_on_item_activated()

#endregion

#func _gui_input(event: InputEvent) -> void:
	#if event.is_action_pressed("cut"):
		#_cut()
	#elif event.is_action_pressed("copy"):
		#_copy()
	#elif event.is_action_pressed("paste"):
		#_paste()
	#elif event.is_action_pressed("delete"):
		#_delete()
	#elif event.is_action_pressed("make_group"):
		#make_group()
	#elif event.is_action_pressed("make_slide"):
		#make_slide()

func _on_nothing_selected() -> void:
	pass
	#deselect_all()

func _get_relative_item_direction(from: TreeItem, to: TreeItem) -> int:
	if from == to: return 0
	var next := from.get_next_in_tree()
	while next:
		if next == to:
			return -1
		next = next.get_next_in_tree()
	return 1

func _on_multi_selected(item: TreeItem, _column: int, selected: bool) -> void:
	#print(item.get_index())
	#prints("Selected item", item, column, selected)
	await get_tree().process_frame
	if Input.is_action_pressed("multi_select"):
		if selected:
			#item.select(column)
			_select_item(item)
			_on_item_activated()
		#else:
			#pass
			#item.deselect(column)
			#item.deselect(0)
			#item.deselect(1)
	elif Input.is_action_pressed("group_select"):
		if selected:
			var last_selected: TreeItem 
			var current_selected := get_next_selected(null)
			while current_selected:
				if current_selected == item: break
				last_selected = current_selected
				current_selected = get_next_selected(last_selected)
			if not last_selected:
				_select_item(item)
			else:
				var dir := _get_relative_item_direction(last_selected, item)
				var from: TreeItem
				var to: TreeItem
				if dir == 0:
					_deselect_item(item)
				elif dir == 1:
					from = item
					to = last_selected
				else:
					from = last_selected
					to = item
				var next := from
				while next:
					_select_item(next)
					if next == to: break
					next = next.get_next_in_tree()
			_on_item_activated()
		#else:
			#item.deselect(0)
			#item.deselect(1)
	elif selected:
		deselect_all()
		#item.select(column)
		_select_item(item)
		_on_item_activated()
	else:
		if item.is_selected(0) or item.is_selected(1):
			_select_item(item)
		else:
			_deselect_item(item)
	#else:
		#deselect_all()

func _on_item_edited() -> void:
	var item := get_selected()
	var node := item.get_metadata(0) as ClassNode
	node.update_value(item)
	WhiteboardManager.reprocess_tree()
	#print(node.get_printable_data())

func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	#prints((item.get_metadata(0) as ClassNode).get_printable_data(), column, id, mouse_button_index)
	pass

func _on_item_activated(ignore_collapsed := false) -> void:
	#reset_colors()
	var item := get_next_selected(null)
	if not item: return
	var next := get_next_selected(item)
	while next:
		item = next
		next = get_next_selected(item)
	#item.set_custom_color(0, Color.GREEN)
	#_current_item = item
	var node := item.get_metadata(0) as ClassNode
	if node.is_leaf() or not item.collapsed or ignore_collapsed:
		node_selected.emit(node)
		return 
	var group := node as ClassGroup
	var last_child: ClassNode
	last_child = group if group.children.is_empty() else group.children[-1]
	node_selected.emit(last_child)

func set_current_item(item: TreeItem) -> void:
	#print("setting current item")
	#reset_colors()
	deselect_all()
	_current_item = item
	_select_item(_current_item)
	#_on_item_activated()
	#_current_item.set_custom_color(0, Color.GREEN)
	#node_selected.

func _on_cell_selected() -> void:
	var item := get_selected()
	_on_multi_selected(item, 0, true)


func _on_item_collapsed(item: TreeItem) -> void:
	#if not item.collapsed: return
	deselect_all()
	_select_item(item)
	_on_item_activated(true)
	#_on_multi_selected(item, 0, true)
