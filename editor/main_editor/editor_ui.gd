class_name EditorUI
extends Control


signal updated
signal widget_selected(widget: Widget)

enum PenThickness {
	XS = 1,
	S = 3,
	M = 5,
	L = 8,
	XL = 16,
	XXL = 32
}

@export var test_class: ClassRoot

var _pen_color_changed: bool = false
var current_item_tree: TreeItem
var select_item_index_disabled: bool = false
var edit_subtitles := false
var current_node: ClassNode

@onready var menu_btn_edit: MenuButton = %EditMenuButton
@onready var menu_btn_insert: MenuButton = %InsertMenuButton
@onready var tree_manager: TreeManagerEditor = %IndexTree
@onready var pen_thickness_slider: HSlider = %PenThicknessSlider
@onready var pen_color_picker: ColorPickerButton = %ColorPickerButton
@onready var subtitles_box: TextEdit = %SubtitlesBox
@onready var custom_color_popup: Popup = %CustomColorPopup
@onready var color_picker: ColorPicker = %ColorPicker


func _ready() -> void:
	EditorManager.set_editor_ui(self)
	#WhiteboardManager.pen_pressed.connect(_on_pen_started_drawing)
	#WhiteboardManager.pen_lifted.connect(_on_pen_stopped_drawing)
	menu_btn_edit.get_popup().id_pressed.connect(_on_menu_btn_edit)
	menu_btn_insert.get_popup().id_pressed.connect(_on_menu_btn_insert)
	tree_manager.build(EditorManager.root)
	#if test_class:
		#tree_manager.build(test_class)

# Setup the control panel with the current resources class
func _setup():
	#_current_node_changed(resources_class._current_node)
	print("ControlPanel setup complete")

#region Menu Edit

func _on_menu_btn_edit(id: int) -> void:
	if id == 1:
		tree_manager._copy()
	if id == 2:
		tree_manager._cut()
	if id == 3:
		tree_manager._paste()
	if id == 4:
		tree_manager._delete()

func _disabled_toggle_edit_button(active: bool) -> void:
	menu_btn_edit.disabled = active

#region Menu Insert

# Handle the insert menu button actions
func _on_menu_btn_insert(id: int) -> void:
	if id == 1:
		_add_group()
	if id == 2:
		_add_group()
	if id == 3:
		_make_group()
	if id == 4:
		_add_clear()
	if id == 5:
		_add_pause()
	if id == 6:
		_add_slide()
	if id == 7:
		_push_slide()
	if id == 8:
		_add_image()
	if id == 9:
		_add_video()
	if id == 10:
		_add_play_video()
	if id == 11:
		_add_seek_video()

func _add_entity(entity: Entity) -> void:
	var node := ClassLeaf.new()
	node.entity = entity
	tree_manager.add_node(node)

func _add_group() -> void:
	var node := ClassGroup.new()
	tree_manager.add_node(node)

func _make_group() -> void:
	tree_manager.make_group()
	
func _add_slide() -> void:
	var node := ClassSlide.new()
	tree_manager.add_node(node)

func _push_slide() -> void:
	tree_manager.make_slide()

func _add_clear() -> void:
	var entity = ClearEntity.new()
	_add_entity(entity)

func _add_pause() -> void:
	var entity = PausePlaybackEntity.new()
	_add_entity(entity)

func _add_pen_color(color: Color) -> void:
	var entity := PenColorEntity.new()
	entity.color = color
	_add_entity(entity)

func _add_pen_thickness(thickness: float) -> void:
	var entity := PenThicknessEntity.new()
	entity.thickness = thickness
	_add_entity(entity)

func add_image(path: String) -> void:
	var entity := ImageEntity.new()
	var converted_path := start_image_conversion(entity, path)
	prints("Converted path", converted_path)
	entity.image_path = converted_path
	_add_entity(entity)

func add_video(path: String) -> void:
	var entity := VideoEntity.new()
	var converted_path := start_video_conversion(entity, path)
	prints("Converted path", converted_path)
	entity.video_path = converted_path
	_add_entity(entity)

func _add_subtitles(text: String) -> void:
	var entity := SubtitleEntity.new()
	entity.text = text
	_add_entity(entity)

func _disabled_toggle_insert_button(active: bool) -> void:
	menu_btn_insert.disabled = active

func _add_image() -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG):
		DisplayServer.file_dialog_show("Open File", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["*.png,*.jpg,*.svg,*.bmp"], _on_image_selected)

func _add_video() -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG):
		DisplayServer.file_dialog_show("Open File", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["*.mp4,*.mkv,*.webm,*.m4a"], _on_video_selected)

func _add_play_video() -> void:
	var entity := PlayVideoEntity.new()
	_add_entity(entity)

func _add_seek_video() -> void:
	var entity := SeekVideoEntity.new()
	_add_entity(entity)

func _on_image_selected(_status: bool, selected_paths: PackedStringArray, _selected_filter_index: int) -> void:
	add_image(selected_paths[0])

func _on_video_selected(_status: bool, selected_paths: PackedStringArray, _selected_filter_index: int) -> void:
	add_video(selected_paths[0])

func start_video_conversion(entity: VideoEntity, input_video_path: String) -> String:
	return EditorManager.convert_video(entity, input_video_path)

func start_image_conversion(entity: ImageEntity, input_image_path: String) -> String:
	return EditorManager.convert_image(entity, input_image_path)

func _on_confirm_subtitles() -> void:
	var text := subtitles_box.text
	if edit_subtitles:
		var leaf := current_node as ClassLeaf
		var entity := leaf.entity as SubtitleEntity
		if not entity: return
		entity.set_text(text)
	else:
		_add_subtitles(text)
		subtitles_box.clear()

# func _add_zoom():
	# var entity_zoom = ZoomEntity.new()
	# var data_new = {
	# 	"type": "Zoom",
	# 	"entity_id": entity_zoom.entity_id,
	# 	"entiy_properties": [] 
	# }
	
		
#endregion


#region Whiteboard Interactions

# Toggle audio recording
func _on_toggle_audio_pressed(active: bool) -> void:
	EditorManager.set_pen_mode(EditorManager.PenMode.DISABLED)
	if active:
		EditorManager.record_audio()
	else:
		EditorManager.stop_recording()

# Toggle pen mode
func _on_button_pen_toggled(active: bool) -> void:
	print("Pen: ", active)
	if active:
		EditorManager.set_pen_mode(EditorManager.PenMode.DRAW)
	else:
		EditorManager.set_pen_mode(EditorManager.PenMode.DISABLED)

# Request to detach the whiteboard
func _on_button_detach_pressed() -> void:
	WhiteboardManager.detach_whiteboard()

 #Toggle drag mode
func _on_button_drag_toggled(active: bool) -> void:
	print("Drag: ", active)
	if active:
		EditorManager.set_pen_mode(EditorManager.PenMode.DRAG)
	else:
		EditorManager.set_pen_mode(EditorManager.PenMode.DISABLED)

# Toggle resize mode
func _on_button_resize_toggled(active: bool) -> void:
	print("Resize: ", active)
	if active:
		EditorManager.set_pen_mode(EditorManager.PenMode.RESIZE)
	else:
		EditorManager.set_pen_mode(EditorManager.PenMode.DISABLED)

func _on_select_button_toggled(active: bool) -> void:
	if active:
		EditorManager.set_pen_mode(EditorManager.PenMode.SELECT)
	else:
		EditorManager.set_pen_mode(EditorManager.PenMode.DISABLED)

func _whiteboard_nodes_selection(nodes: Array[ClassLeaf]):
	if select_item_index_disabled or nodes.size() == 0:
		return
	
	var t_items: Array[TreeItem] = []
	for node in nodes:
		var t_item = tree_manager.find_item_by_node(node)
		if t_item:
			t_items.append(t_item)
	
	if t_items.size() > 0:
		tree_manager.deselect_all()
		# Set first on rendering order as current node an others as selected
		var last = t_items.pop_back()
		var node = last.get_metadata(0)
		#_bus_core.current_node_changed.emit(node)		
		for t_item: TreeItem in t_items:
			t_item.select(0)
			tree_manager.multi_selected.emit(t_item, 0, true)
	
#endregion


#region Tree Index


# Select an item in the tree and update the current node
func _on_item_activated() -> void:
	if select_item_index_disabled:
		return
	var item = tree_manager.get_selected()
	var node = item.get_metadata(0)
	#_bus_core.current_node_changed.emit(node)
	#_bus.seek_node.emit(node)
	#PersistenceEditor._epilog_events(PersistenceEditor.Events.SEEK_PANEL, [node] )
	
func _disabled_toggle_select_item_index(active: bool) -> void:
	select_item_index_disabled = active

# Update the current node
func _current_node_changed(current_node):
	#get_tree().call_group(&"skipped_before_play", "clear_before_play")
	if current_item_tree != null:
		current_item_tree.set_custom_color(0, Color.GRAY)
	current_item_tree = tree_manager.find_item_by_node(current_node)
	tree_manager.scroll_to_item(current_item_tree, true)
	current_item_tree.set_custom_color(0, Color.LIME_GREEN)
	#_current_node = current_node
	_update_pen_settings_from_node(current_node)

func _update_pen_settings_from_node(node: ClassNode):
	if not is_instance_valid(node):
		return

	if node is ClassLeaf:
		var entity = node.entity
		if not is_instance_valid(entity):
			return

		if entity is LineEntity:
			_set_colorpicker_silently(entity.pen_color)
			_set_thickness_silently(entity.pen_thickness)
		elif entity is PenColorEntity:
			_set_colorpicker_silently(entity.color)
		elif entity is PenThicknessEntity:
			_set_thickness_silently(entity.thickness)

## Sets the color without adding a new node
func _set_colorpicker_silently(color: Color):
	pen_color_picker.color = color

## Sets a value for the slider without adding a new node
func _set_thickness_silently(value: float):
	pen_thickness_slider.value = value

# Show or hide items from a group if it is collapsed
#func _on_item_collapse(item: TreeItem) -> void:
	#if item == current_item_tree:
		#_execute_after_rendering()

# Emit class selected nodes from panel items
func _on_multi_selected(item: TreeItem, column: int, selected: bool):
	if select_item_index_disabled:
		return
	var node = item.get_metadata(0)
	#_bus.class_node_selected.emit(node, selected)

func _clear_selection():
	tree_manager.deselect_all()

func _on_color_picker_changed(color: Color) -> void:
	#_pending_pen_color = color
	WhiteboardManager.set_pen_color(color)
	_add_pen_color(WhiteboardManager.get_pen_color())
	#_pen_color_changed = true
	#_pen_color_changed_first = true
	
func _on_color_picker_closed() -> void:
	if _pen_color_changed:
		_add_pen_color(WhiteboardManager.get_pen_color())
		#_on_pen_color_changed(_pending_pen_color)
		_pen_color_changed = false

#endregion

func _on_index_tree_node_selected(node: ClassNode) -> void:
	var root := WhiteboardManager.get_root_widget()
	var widget := root.search_widget_by_class_node(node)
	root.jump_to_widget(widget)
	current_node = node
	_check_special_behavior()
	widget_selected.emit(widget)

# Here we can check if the control panel has to do something special
# after an item is selected, like changing to "edit mode" for an entity
func _check_special_behavior() -> void:
	if not current_node.is_leaf(): return
	var leaf := current_node as ClassLeaf
	var entity := leaf.entity
	if entity is SubtitleEntity:
		edit_subtitles = true
		subtitles_box.text = (entity as SubtitleEntity).text
	else:
		edit_subtitles = false
		subtitles_box.text = ""

func _on_index_tree_updated() -> void:
	updated.emit()

func _change_pen_thickness(thickness: PenThickness) -> void:
	WhiteboardManager.set_pen_thickness(thickness)
	_add_pen_thickness(thickness)

func _on_pen_thickness_options_item_selected(index: int) -> void:
	match index:
		0: _change_pen_thickness(PenThickness.XS)
		1: _change_pen_thickness(PenThickness.S)
		2: _change_pen_thickness(PenThickness.M)
		3: _change_pen_thickness(PenThickness.L)
		4: _change_pen_thickness(PenThickness.XL)
		5: _change_pen_thickness(PenThickness.XXL)

func _on_pen_color_options_item_selected(index: int) -> void:
	match index:
		0: _on_color_picker_changed(Color.WHITE)
		1: _on_color_picker_changed(Color.RED)
		2: _on_color_picker_changed(Color.BLUE)
		3: _on_color_picker_changed(Color.LIME)
		4: _on_color_picker_changed(Color.YELLOW)
		5: _on_color_picker_changed(Color.FUCHSIA)
		6: _on_color_picker_changed(Color.ORANGE)
		7: _on_color_picker_changed(Color.AQUA)
		8: _on_color_picker_changed(Color.WEB_GRAY)
		9: custom_color_popup.popup()

func _on_custom_color_popup_hide() -> void:
	_on_color_picker_changed(color_picker.color)
