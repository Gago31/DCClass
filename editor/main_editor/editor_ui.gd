class_name EditorUI
extends Control


signal updated
signal widget_selected(widget: Widget)
signal save_pressed
signal export_pressed

enum FileMenuItem {
	SAVE,
	EXPORT
}

enum EditMenuItem {
	COPY = 1,
	CUT = 2,
	PASTE = 3,
	DELETE = 5
}

enum InsertMenuItem {
	ADD_GROUP,
	ADD_SLIDE,
	MAKE_GROUP,
	MAKE_SLIDE,
	PAUSE,
	CLEAR,
	ADD_IMAGE,
	ADD_VIDEO,
	PLAY_VIDEO,
	SEEK_VIDEO,
	WAIT
}

enum PenThickness {
	XS = 1,
	S = 3,
	M = 5,
	L = 8,
	XL = 16,
	XXL = 32
}

var _pen_color_changed: bool = false
var current_item_tree: TreeItem
var select_item_index_disabled: bool = false
var edit_subtitles := false
var current_node: ClassNode

@onready var menu_btn_file: MenuButton = %FileMenuButton
@onready var menu_btn_edit: MenuButton = %EditMenuButton
@onready var menu_btn_insert: MenuButton = %InsertMenuButton
@onready var tree_manager: TreeManagerEditor = %IndexTree
@onready var pen_thickness_slider: HSlider = %PenThicknessSlider
@onready var pen_color_picker: ColorPickerButton = %ColorPickerButton
@onready var subtitles_box: TextEdit = %SubtitlesBox
@onready var custom_color_popup: Popup = %CustomColorPopup
@onready var color_picker: ColorPicker = %ColorPicker
@onready var play_button: Button = %PlayButton
@onready var stop_button: Button = %StopButton
@onready var time_label: Label = %TimeCurrent
@onready var zoom_slider: HSlider = %ZoomSlider
@onready var play_icon: Texture2D = get_theme_icon("play", stop_button.theme_type_variation)
@onready var pause_icon: Texture2D = get_theme_icon("pause", stop_button.theme_type_variation)
@onready var pen_color_options: OptionButton = %PenColorOptions
@onready var pen_thickness_options: OptionButton = %PenThicknessOptions


func _ready() -> void:
	EditorManager.set_editor_ui(self)
	#WhiteboardManager.pen_pressed.connect(_on_pen_started_drawing)
	#WhiteboardManager.pen_lifted.connect(_on_pen_stopped_drawing)
	menu_btn_edit.get_popup().id_pressed.connect(_on_menu_btn_edit)
	menu_btn_insert.get_popup().id_pressed.connect(_on_menu_btn_insert)
	menu_btn_file.get_popup().id_pressed.connect(_on_menu_btn_file)
	_setup_shortcuts()
	tree_manager.build(EditorManager.root)
	WhiteboardManager.play_state_changed.connect(_on_play_state_changed)

func _process(_delta: float) -> void:
	var root := WhiteboardManager.get_root_widget()
	if not root or not is_instance_valid(root): return
	var current_time_str := TimeString.from_seconds(root.play_time, false)
	var total_time_str := TimeString.from_seconds(root.end_time, false)
	time_label.text = "%s / %s" % [current_time_str, total_time_str]

func _setup_shortcuts() -> void:
	_setup_file_menu_shortcuts()
	_setup_edit_menu_shortcuts()
	_setup_insert_menu_shortcuts()

func _set_menu_item_shortcut(menu_btn: MenuButton, id: int, key: Key, ctrl := false, shift := false) -> void:
	var shortcut := Shortcut.new()
	var input := InputEventKey.new()
	input.keycode = key
	if ctrl:
		input.ctrl_pressed = true
		input.command_or_control_autoremap = true
	if shift:
		input.shift_pressed = true
	shortcut.events = [input]
	menu_btn.get_popup().set_item_shortcut(id, shortcut)

func _setup_file_menu_shortcuts() -> void:
	_set_menu_item_shortcut(menu_btn_file, FileMenuItem.SAVE, KEY_S, true)
	_set_menu_item_shortcut(menu_btn_file, FileMenuItem.EXPORT, KEY_E, true)

func _setup_edit_menu_shortcuts() -> void:
	_set_menu_item_shortcut(menu_btn_edit, EditMenuItem.COPY, KEY_C, true)
	_set_menu_item_shortcut(menu_btn_edit, EditMenuItem.CUT, KEY_X, true)
	_set_menu_item_shortcut(menu_btn_edit, EditMenuItem.PASTE, KEY_V, true)
	_set_menu_item_shortcut(menu_btn_edit, EditMenuItem.DELETE, KEY_DELETE)

func _setup_insert_menu_shortcuts() -> void:
	_set_menu_item_shortcut(menu_btn_insert, InsertMenuItem.ADD_GROUP, KEY_G, true, true)
	_set_menu_item_shortcut(menu_btn_insert, InsertMenuItem.ADD_SLIDE, KEY_L, true, true)
	_set_menu_item_shortcut(menu_btn_insert, InsertMenuItem.MAKE_GROUP, KEY_G, true)
	_set_menu_item_shortcut(menu_btn_insert, InsertMenuItem.MAKE_SLIDE, KEY_L, true)

# Setup the control panel with the current resources class
func _setup():
	#_current_node_changed(resources_class._current_node)
	print("ControlPanel setup complete")

#region Menu Edit

func _on_menu_btn_edit(id: int) -> void:
	match id:
		EditMenuItem.COPY:
			tree_manager._copy()
		EditMenuItem.CUT:
			tree_manager._cut()
		EditMenuItem.PASTE:
			tree_manager._paste()
		EditMenuItem.DELETE:
			tree_manager._delete()

func _disabled_toggle_edit_button(active: bool) -> void:
	menu_btn_edit.disabled = active

#region Menu Insert

# Handle the insert menu button actions
func _on_menu_btn_insert(id: int) -> void:
	match id:
		InsertMenuItem.ADD_GROUP:
			_add_group()
		InsertMenuItem.ADD_SLIDE:
			_add_slide()
		InsertMenuItem.MAKE_GROUP:
			_make_group()
		InsertMenuItem.MAKE_SLIDE:
			_make_slide()
		InsertMenuItem.PAUSE:
			_add_pause()
		InsertMenuItem.CLEAR:
			_add_clear()
		InsertMenuItem.ADD_IMAGE:
			_add_image()
		InsertMenuItem.ADD_VIDEO:
			_add_video()
		InsertMenuItem.PLAY_VIDEO:
			_add_play_video()
		InsertMenuItem.SEEK_VIDEO:
			_add_seek_video()
		InsertMenuItem.WAIT:
			_add_wait()

func _on_menu_btn_file(id: int) -> void:
	if id == 0:
		save_pressed.emit()
	elif id == 1:
		export_pressed.emit()

func _add_entity(entity: Entity, nest := true, select := true) -> void:
	var node := ClassLeaf.new()
	node.entity = entity
	tree_manager.add_node(node, nest, select)

func _delete_entity(entity: Entity) -> void:
	var item := entity._tree_item
	if not item:
		print("No item assigned")
		return
	var parent := item.get_parent()
	var prev := item.get_prev_in_tree()
	parent.remove_child(item)
	entity.delete()
	prev.select(0)
	prev.select(1)

func _add_group() -> void:
	var node := ClassGroup.new()
	tree_manager.add_node(node)

func _make_group() -> void:
	tree_manager.make_group()
	
func _add_slide() -> void:
	var node := ClassSlide.new()
	tree_manager.add_node(node)

func _make_slide() -> void:
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

func _add_wait() -> void:
	var entity := WaitEntity.new()
	entity.duration = 1.0
	_add_entity(entity)

func _on_image_selected(_status: bool, selected_paths: PackedStringArray, _selected_filter_index: int) -> void:
	if selected_paths.is_empty(): return
	add_image(selected_paths[0])

func _on_video_selected(_status: bool, selected_paths: PackedStringArray, _selected_filter_index: int) -> void:
	if selected_paths.is_empty(): return
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
	#print("Pen: ", active)
	if active:
		EditorManager.set_pen_mode(EditorManager.PenMode.DRAW)
	else:
		EditorManager.set_pen_mode(EditorManager.PenMode.DISABLED)

# Request to detach the whiteboard
func _on_button_detach_pressed() -> void:
	WhiteboardManager.detach_whiteboard()

 #Toggle drag mode
func _on_button_drag_toggled(active: bool) -> void:
	#print("Drag: ", active)
	if active:
		EditorManager.set_pen_mode(EditorManager.PenMode.DRAG)
	else:
		EditorManager.set_pen_mode(EditorManager.PenMode.DISABLED)

# Toggle resize mode
func _on_button_resize_toggled(active: bool) -> void:
	#print("Resize: ", active)
	if active:
		EditorManager.set_pen_mode(EditorManager.PenMode.RESIZE)
	else:
		EditorManager.set_pen_mode(EditorManager.PenMode.DISABLED)

func _on_select_button_toggled(active: bool) -> void:
	if active:
		EditorManager.set_pen_mode(EditorManager.PenMode.SELECT)
	else:
		EditorManager.set_pen_mode(EditorManager.PenMode.DISABLED)

#endregion


#region Tree Index

func _disabled_toggle_select_item_index(active: bool) -> void:
	select_item_index_disabled = active

## Sets the color without adding a new node
func _set_colorpicker_silently(color: Color):
	pen_color_picker.color = color

func _clear_selection():
	tree_manager.deselect_all()

func _on_color_picker_changed(color: Color) -> void:
	WhiteboardManager.set_pen_color(color)
	_add_pen_color(WhiteboardManager.get_pen_color())
	
func _on_color_picker_closed() -> void:
	if _pen_color_changed:
		_add_pen_color(WhiteboardManager.get_pen_color())
		_pen_color_changed = false

#endregion

func _on_index_tree_node_selected(node: ClassNode) -> void:
	var root := WhiteboardManager.get_root_widget()
	var widget := root.search_widget_by_class_node(node)
	root.jump_to_widget(widget)
	current_node = node
	_check_special_behavior()
	widget_selected.emit(widget)
	_reflect_context()

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

func get_index_from_thickness() -> int:
	match int(WhiteboardManager.get_pen_thickness()):
		PenThickness.XS: 
			return 0 
		PenThickness.S: 
			return 1 
		PenThickness.M: 
			return 2 
		PenThickness.L: 
			return 3 
		PenThickness.XL: 
			return 4 
		PenThickness.XXL: 
			return 5
		_:
			return 1

func get_id_from_color() -> int:
	match WhiteboardManager.get_pen_color():
		Color.WHITE:
			return 0
		Color.RED:
			return 1
		Color.BLUE:
			return 2
		Color.LIME:
			return 3
		Color.YELLOW:
			return 4
		Color.FUCHSIA:
			return 5
		Color.ORANGE:
			return 6
		Color.AQUA:
			return 7
		Color.WEB_GRAY:
			return 8
		_:
			return 9

func _on_custom_color_popup_hide() -> void:
	_on_color_picker_changed(color_picker.color)

#region Whiteboard control

func _zoom_slider_value_selected(value: float) -> void:
	WhiteboardManager.set_zoom(value)

func _zoom_reset() -> void:
	zoom_slider.value = WhiteboardManager.get_base_zoom()

# Toggle playback stop button.
# If the button is pressed, it will toggle between playing and stopping.
# When playing, the visual widget will begin 
# When stopped, the current  visual widget will be stopped and show his final state.
func _toggle_playback_pause() -> void:
	if tree_manager.dirty:
		WhiteboardManager.reprocess_tree()
		await get_tree().process_frame
	WhiteboardManager.toggle_play_pause()
	_update_play_button()

func _stop_playback() -> void:
	WhiteboardManager.stop_playback()
	_update_play_button()

func _update_play_button() -> void:
	play_button.icon = pause_icon if WhiteboardManager.get_root_widget().is_playing() else play_icon

#endregion

func _on_play_state_changed(_state: Widget.PlayState) -> void:
	_update_play_button()

func _reflect_context() -> void:
	pen_color_options.selected = get_id_from_color()
	pen_thickness_options.selected = get_index_from_thickness()

func _on_fullscreen_button_pressed() -> void:
	WhiteboardManager.toggle_fullscreen()
