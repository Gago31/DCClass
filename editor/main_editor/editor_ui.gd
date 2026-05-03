class_name EditorUI
extends Control


signal updated
signal widget_selected(widget: Widget)

@export var test_class: ClassRoot

@onready var menu_btn_edit: MenuButton = %EditMenuButton
@onready var menu_btn_insert: MenuButton = %InsertMenuButton

#@onready var btn_zoom: CheckButton = %ZoomButton

@onready var tree_manager: TreeManagerEditor = %IndexTree

@onready var pen_color_picker: ColorPickerButton = %ColorPickerButton
var _pen_color_changed: bool = false
var _pending_pen_color: Color = Color.WHITE

@onready var pen_thickness_slider: HSlider = %PenThicknessSlider
var _pending_pen_thickness: float = 3.0

@onready var subtitles_box: TextEdit = %SubtitlesBox

#var _current_node: ClassNode
#var _class_index: ClassIndex
var current_item_tree: TreeItem
var select_item_index_disabled: bool = false

# solo será true 1 vez con el primer trazo
var _first_stroke: bool = true
var _pen_color_changed_first: bool = false
var _pen_thickness_changed_first: bool = false

func _ready() -> void:
	EditorManager.set_editor_ui(self)
	#_bus_core.current_node_changed.connect(_current_node_changed)
	#_bus.update_treeindex.connect(_setup_index_class)

	menu_btn_edit.get_popup().id_pressed.connect(_on_menu_btn_edit)
	menu_btn_insert.get_popup().id_pressed.connect(_on_menu_btn_insert)
	
	#tree_manager.item_activated.connect(_on_item_activated)
	
	# Node selection
	#tree_manager.item_collapsed.connect(_on_item_collapse)
	#tree_manager.multi_selected.connect(_on_multi_selected)
	
	#_bus.execute_after_rendering.connect(_execute_after_rendering)
	#_bus.clear_selection.connect(_clear_selection)
	#_bus.whiteboard_nodes_selected.connect(_whiteboard_nodes_selection)
	
	#for i in 5:
		##var item := TreeItem.new()
		#var item := tree_manager.create_item()
		#item.set_text(0, "Item %d" % i)
	
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

func add_image(path: String) -> void:
	var entity := ImageEntity.new()
	var tmp_path := entity.save_resource(path)
	entity.image_path = tmp_path
	_add_entity(entity)

func add_video(path: String) -> void:
	var entity := VideoEntity.new()
	# TODO: convert video, wait for thread completion and assign the video
	var converted_path := start_video_conversion(entity, path)
	#var converted_path := ""
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

func _on_image_selected(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int) -> void:
	#EditorManager.add_image(selected_paths[0])
	add_image(selected_paths[0])

func _on_video_selected(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int) -> void:
	#EditorManager.add_video(selected_paths[0])
	add_video(selected_paths[0])

func start_video_conversion(entity: VideoEntity, input_video_path: String) -> String:
	return EditorManager.convert_video(entity, input_video_path)

func _on_confirm_subtitles() -> void:
	var text := subtitles_box.text
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

# Show or hide all the children of a group if it is collapsed
#func _execute_after_rendering():
	#if select_item_index_disabled:
		#return
	#if _current_node._node_controller is GroupController and current_item_tree.collapsed:
		#_current_node._node_controller.skip_all_children()
		#_bus.show_outlines.emit()
	#else:
		#get_tree().call_group(&"skipped_before_play", "clear_before_play")
		#_bus.clear_outlines.emit()

func _clear_selection():
	tree_manager.deselect_all()

func _on_pen_thickness_changed():
	var entity := PenThicknessEntity.new()
	entity.thickness = _pending_pen_thickness
	_add_entity(entity)

func _on_pen_color_changed(color: Color) -> void:
	var entity := PenColorEntity.new()
	entity.color = color
	_add_entity(entity)

func _on_color_picker_changed(color: Color) -> void:
	_pending_pen_color = color
	_pen_color_changed = true
	_pen_color_changed_first = true
	
func _on_color_picker_closed() -> void:
	if _pen_color_changed:
		_on_pen_color_changed(_pending_pen_color)
		_pen_color_changed = false
	
func _on_thickness_slider_changed(changed: bool) -> void:
	if not changed: return
	_pending_pen_thickness = pen_thickness_slider.value
	_pen_thickness_changed_first = true

func _on_pen_started_drawing() -> void:
	if _first_stroke:
		if _pen_color_changed_first and !_pen_thickness_changed_first:
			EditorManager.add_pen_thickness_change(_pending_pen_thickness)
		
		if _pen_thickness_changed_first and !_pen_color_changed_first:
			EditorManager.add_pen_color_change(pen_color_picker.color)

		if !_pen_thickness_changed_first and !_pen_color_changed_first:
			EditorManager.add_pen_color_change(pen_color_picker.color)
			EditorManager.add_pen_thickness_change(_pending_pen_thickness)

		_first_stroke = false
		
#endregion


func _on_index_tree_node_selected(node: ClassNode) -> void:
	var root := WhiteboardManager.get_root_widget()
	var widget := root.search_widget_by_class_node(node)
	root.jump_to_widget(widget)
	widget_selected.emit(widget)


func _on_index_tree_updated() -> void:
	updated.emit()
