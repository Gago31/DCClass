class_name ControlPanel
extends MarginContainer

@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")
@onready var _bus: EditorEventBus = Engine.get_singleton(&"EditorSignals")

@onready var menu_btn_edit: MenuButton = %EditMenuButton
@onready var menu_btn_insert: MenuButton = %InsertMenuButton

@onready var btn_audio: CheckButton = %AudioButton
@onready var btn_pen: CheckButton = %PenButton
@onready var btn_detach: Button = %DetachButton
@onready var btn_drag: CheckButton = %DragButton
@onready var btn_resize: CheckButton = %ResizeButton

#@onready var btn_zoom: CheckButton = %ZoomButton

@onready var tree_manager: TreeManagerEditor = %IndexTree

@onready var pen_color_picker: ColorPickerButton = %ColorPickerButton
@onready var pen_color_label: Label = %ColorPickerLabel
@onready var pen_color_container: HBoxContainer = %PenColorContainer
var _pen_color_changed: bool = false
var _pending_pen_color: Color = Color.WHITE

@onready var pen_thickness_slider: HSlider = %PenThicknessSlider
@onready var pen_thickness_label: Label = %PenThicknessLabel
@onready var pen_thickness_container: HBoxContainer = %PenThicknessContainer
var _pen_thickness_timer: Timer
var _pending_pen_thickness: float = 3.0

var resources_class: ResourcesClassEditor
@onready var subtitles_box: TextEdit = %SubtitlesBox
@onready var confirm_subtitles: Button = %ConfirmSubtitles

var _current_node: ClassNode
var _class_index: ClassIndex
var current_item_tree: TreeItem
var select_item_index_disabled: bool = false

# solo será true 1 vez con el primer trazo
var _first_stroke: bool = true
var _pen_color_changed_first: bool = false
var _pen_thickness_changed_first: bool = false

func _ready() -> void:
	_bus_core.current_node_changed.connect(_current_node_changed)
	_bus.update_treeindex.connect(_setup_index_class)

	menu_btn_edit.get_popup().id_pressed.connect(_on_menu_btn_edit)
	_bus.disabled_toggle_edit_button.connect(_disabled_toggle_edit_button)
	
	menu_btn_insert.get_popup().id_pressed.connect(_on_menu_btn_insert)
	_bus.disabled_toggle_insert_button.connect(_disabled_toggle_insert_button)

	btn_audio.toggled.connect(_on_toggle_audio_pressed)
	_bus.disabled_toggle_audio_button.connect(_disabled_toggle_audio_button)
	
	btn_pen.toggled.connect(_on_button_pen_toggled)
	_bus.disabled_toggle_pen_button.connect(_disabled_toggle_pen_button)
	
	_bus.pen_started_drawing.connect(_on_pen_started_drawing)
	
	btn_detach.pressed.connect(_on_button_detach_pressed)

	btn_drag.toggled.connect(_on_button_drag_toggled)
	_bus.disabled_toggle_drag_button.connect(_disabled_toggle_drag_button)

	btn_resize.toggled.connect(_on_button_resize_toggled)
	_bus.disabled_toggle_resize_button.connect(_disabled_toggle_resize_button)

	tree_manager.item_activated.connect(_on_item_activated)
	_bus.disabled_toggle_select_item_index.connect(_disabled_toggle_select_item_index)
	
	# Node selection
	tree_manager.item_collapsed.connect(_on_item_collapse)
	tree_manager.multi_selected.connect(_on_multi_selected)
	_bus.execute_after_rendering.connect(_execute_after_rendering)
	_bus.clear_selection.connect(_clear_selection)
	_bus.whiteboard_nodes_selected.connect(_whiteboard_nodes_selection)


	pen_thickness_slider.value_changed.connect(_on_thickness_slider_changed)
	
	_pen_thickness_timer = Timer.new()
	_pen_thickness_timer.wait_time = 0.3
	_pen_thickness_timer.one_shot = true
	_pen_thickness_timer.timeout.connect(_on_pen_thickness_changed)
	add_child(_pen_thickness_timer)
	
	pen_color_picker.color_changed.connect(_on_color_picker_changed)
	pen_color_picker.get_popup().connect("popup_hide", _on_color_picker_closed)
	
	confirm_subtitles.pressed.connect(_on_confirm_subtitles)

# Setup the control panel with the current resources class
func _setup():
	resources_class = PersistenceEditor.resources_class
	
	if not is_instance_valid(resources_class):
		printerr("ERROR: resources_class is not valid!")
		# Intenta inicializar PersistenceEditor si es necesario
		if PersistenceEditor.resources_class == null:
			printerr("PersistenceEditor.resources_class is null!")
			return
	
	_setup_index_class()
	_current_node_changed(resources_class._current_node)
	
	print("ControlPanel setup complete")

#region Menu Edit

func _on_menu_btn_edit(id: int) -> void:
	if id == 1:
		_copy_to_clipboard()
	if id == 2:
		_cut_to_clipboard()
	if id == 3:
		_paste()
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
	
	PersistenceEditor.clipboard.clear()
	PersistenceEditor.clipboard_clear_files()

	for node in nodes_copy:
		if node is ClassLeaf:
			var node_copy: ClassNode = node.copy_tmp()
			node_copy._setup_controller(false)
			PersistenceEditor.clipboard.append(node_copy)

		
		elif node is ClassGroup:
			var data_new = {
				"name": "Group",
				"type": "ClassGroup",
				"childrens": []
			}
			var new_node = ClassGroup.deserialize(data_new)
			PersistenceEditor.clipboard.append(new_node)

		elif node is ClassSlide:
			var data_new = {
				"name": "Slide",
				"type": "ClassSlide",
				"childrens": []
			}
			var new_node = ClassSlide.deserialize(data_new)
			PersistenceEditor.clipboard.append(new_node)

func _cut_to_clipboard() -> void:
	_copy_to_clipboard()
	_delete()

func _paste() -> void:
	var first = tree_manager.get_next_selected(null)
	if first != null:
		PersistenceEditor.resources_class._current_node = first.get_metadata(0)
	_bus.paste_class_nodes.emit()
	PersistenceEditor._epilog_events(PersistenceEditor.Events.EDIT_AUDIO)


func _delete() -> void:
	var first = tree_manager.get_next_selected(null)
	if first == null:
		return
	var nodes_del: Array[ClassNode] = []
	var current = first
	
	while current:
		nodes_del.append(current.get_metadata(0))
		current = tree_manager.get_next_selected(current)
	
	_bus.delete_class_nodes.emit(nodes_del)
	PersistenceEditor._epilog_events(PersistenceEditor.Events.EDIT_AUDIO)

	
#endregion


#region Menu Insert

# Handle the insert menu button actions
func _on_menu_btn_insert(id: int) -> void:
	if id == 1:
		_add_group()
	if id == 2:
		_push_group()
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
	#if id == 10:
		#_add_subtitles()

func _disabled_toggle_insert_button(active: bool) -> void:
	menu_btn_insert.disabled = active

# Add a new group at the beginning of the current node
func _add_group() -> void:
	var data_new = {
		"name": "Group",
		"type": "ClassGroup",
		"childrens": []
	}
	var class_node = ClassGroup.deserialize(data_new)
	var first = tree_manager.get_next_selected(null)
	if first != null:
		PersistenceEditor.resources_class._current_node = first.get_metadata(0)
	_bus.add_class_group.emit(class_node, true)

# Push a new group to the end of the current node
func _push_group() -> void:
	var data_new = {
		"name": "Group",
		"type": "ClassGroup",
		"childrens": []
	}
	var class_node = ClassGroup.deserialize(data_new)
	var first = tree_manager.get_next_selected(null)
	if first != null:
		PersistenceEditor.resources_class._current_node = first.get_metadata(0)
	_bus.add_class_group.emit(class_node, false)

func _make_group() -> void:
	var first = tree_manager.get_next_selected(null)

	if first == null:
		return
	
	var nodes_to_group: Array[ClassNode] = []
	var current = first
	
	while current:
		nodes_to_group.append(current.get_metadata(0))
		current = tree_manager.get_next_selected(current)
	
	PersistenceEditor.clipboard.clear()
	PersistenceEditor.clipboard_clear_files()

	for node in nodes_to_group:
		PersistenceEditor.clipboard.append(node)
	_bus.make_group.emit()

#region Slide
# Add a new slide to the end of the current node
func _add_slide() -> void:
	var data_new = {
		"name": "Slide",
		"type": "ClassSlide",
		"childrens": []
	}
	var class_node = ClassSlide.deserialize(data_new)
	var first = tree_manager.get_next_selected(null)
	if first != null:
		PersistenceEditor.resources_class._current_node = first.get_metadata(0)
	_bus.add_class_slide.emit(class_node, true)

# Push a new slide to the end of the current node
func _push_slide() -> void:
	var data_new = {
		"name": "Slide",
		"type": "ClassSlide",
		"childrens": []
	}
	var class_node = ClassSlide.deserialize(data_new)
	var first = tree_manager.get_next_selected(null)
	if first != null:
		PersistenceEditor.resources_class._current_node = first.get_metadata(0)
	_bus.add_class_slide.emit(class_node, false)
	
#endregion


# Add a clear entity after the current node
func _add_clear() -> void:
	var entity_clear = ClearEntity.new()
	var data_new = {
		"type": "ClassLeaf",
		"entity_id": entity_clear.entity_id,
		"entity_properties": []
	}
	var class_node = ClassLeaf.deserialize(data_new)
	var first = tree_manager.get_next_selected(null)
	if first != null:
		PersistenceEditor.resources_class._current_node = first.get_metadata(0)
	_bus.add_class_leaf.emit(class_node)

func _add_pause() -> void:
	var entity_pause = PausePlaybackEntity.new()
	var data_new = {
		"type": "ClassLeaf",
		"entity_id": entity_pause.entity_id,
		"entity_properties": []
	}
	var class_node = ClassLeaf.deserialize(data_new)
	var first = tree_manager.get_next_selected(null)
	if first != null:
		PersistenceEditor.resources_class._current_node = first.get_metadata(0)
	_bus.add_class_leaf.emit(class_node)

func _add_image() -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG):
		DisplayServer.file_dialog_show("Open File", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["*.png,*.jpg,*.svg,*.bmp"], _on_image_selected)

func _add_video() -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG):
		DisplayServer.file_dialog_show("Open File", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["*.mp4,*.mkv,*.webm,*.m4a"], _on_video_selected)

func _on_confirm_subtitles() -> void:
	var text := subtitles_box.text
	var entity_subtitle := SubtitleEntity.new()
	var subtitle_data := {
		"text": text 
	}
	entity_subtitle.load_data(subtitle_data)
	_bus.add_class_leaf_entity.emit(entity_subtitle, [{
		"position:x": 0,
		"position:y": 0,
		"property_type": "PositionEntityProperty"
	}])
	subtitles_box.clear()

func _on_image_selected(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int) -> void:
	if status == false:
		return
	var path := selected_paths[0]

	var entity_image = ImageEntity.new()
	var tmp_path = entity_image.save_resource(path)
	var image_data = {
		"image_path": tmp_path 
	}
	entity_image.load_data(image_data)
	_bus.emit_signal("add_class_leaf_entity", entity_image, [
								{
									"position:x": 0,
									"position:y": 0,
									"property_type": "PositionEntityProperty"
								}
							])

func _on_video_selected(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int) -> void:
	if status == false:
		return
	var path := selected_paths[0]

	var entity_video := VideoEntity.new()
	var tmp_path := entity_video.save_resource(path)
	
	# TODO: convert video, wait for thread completion and assign the video
	var converted_path := start_video_conversion(entity_video, tmp_path)
	prints("Converted path", converted_path)
	var video_data := {
		"video_path": "resources/videos/%s" % converted_path 
	}
	entity_video.load_data(video_data)
	_bus.emit_signal("add_class_leaf_entity", entity_video, [
		{
			"position:x": 0,
			"position:y": 0,
			"property_type": "PositionEntityProperty"
		}
	])

func start_video_conversion(entity: VideoEntity, input_video_path: String) -> String:
	print("Loading file ", input_video_path)
	var file_path := input_video_path.split("/")[-1]
	var file_name := "".join(file_path.split(".").slice(0, -1))
	var output_name := '%s.webm' % file_name
	#var output_path := "converted/%s" % output_name
	var output_path := "user://tmp/class_editor/resources/videos/%s" % output_name
	
	prints("Output file:", output_name)
	var output = []
	var command_args := [
		"-i", ProjectSettings.globalize_path(input_video_path), 
		"-y", 
		"-vcodec", "libsvtav1",
		"-acodec", "libopus",
		"-crf", 35,
		"-vf", "scale=-2:480", #"scale=-1:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,setsar=1"
		"-preset", 6,
		"-g", 300,
		"-svtav1-params", "tune=0",
		ProjectSettings.globalize_path(output_path)
	]
	var thread_notifier := ThreadNotifier.new()
	add_child(thread_notifier)
	thread_notifier.thread_finished.connect(_on_video_converted.bind(output_path))
	thread_notifier.thread_finished.connect(entity._on_video_converted.bind(output_path))
	thread_notifier.run_thread(OS.execute.bind("ffmpeg", command_args, output))
	return output_name

func _on_video_converted(_result: Variant, output_path: String) -> void:
	pass

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
	_bus.audio_record.emit(active)
	if active:
		PersistenceEditor._epilog(PersistenceEditor.Status.RECORDING_AUDIO)
	else:
		PersistenceEditor._epilog(PersistenceEditor.Status.STOPPED)
		PersistenceEditor._epilog_events(PersistenceEditor.Events.EDIT_AUDIO)

func _disabled_toggle_audio_button(active: bool) -> void:
	btn_audio.disabled = active

# Toggle pen mode
func _on_button_pen_toggled(active: bool) -> void:
	_bus.pen_toggled.emit(active)
	if active:
		PersistenceEditor._epilog(PersistenceEditor.Status.RECORDING_PEN)
	else:
		PersistenceEditor._epilog(PersistenceEditor.Status.STOPPED)
	
func _disabled_toggle_pen_button(active: bool) -> void:
	btn_pen.disabled = active

# Request to detach the whiteboard
func _on_button_detach_pressed() -> void:
	_bus.request_detach.emit()

# Toggle drag mode
func _on_button_drag_toggled(active: bool) -> void:
	_bus.drag_toggled.emit(active)
	if active:
		PersistenceEditor._epilog(PersistenceEditor.Status.RECORDING_DRAG)
	else:
		PersistenceEditor._epilog(PersistenceEditor.Status.STOPPED)

func _disabled_toggle_drag_button(active: bool) -> void:
	btn_drag.disabled = active

# Toggle resize mode
func _on_button_resize_toggled(active: bool) -> void:
	_bus.resize_toggled.emit(active)
	if active:
		PersistenceEditor._epilog(PersistenceEditor.Status.RECORDING_RESIZE)
	else:
		PersistenceEditor._epilog(PersistenceEditor.Status.STOPPED)

func _disabled_toggle_resize_button(active: bool) -> void:
	btn_resize.disabled = active

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
		_bus_core.current_node_changed.emit(node)		
		for t_item: TreeItem in t_items:
			t_item.select(0)
			tree_manager.multi_selected.emit(t_item, 0, true)
	
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
	var item = tree_manager.get_selected()
	var node = item.get_metadata(0)
	_bus_core.current_node_changed.emit(node)
	_bus.seek_node.emit(node)
	PersistenceEditor._epilog_events(PersistenceEditor.Events.SEEK_PANEL, [node] )
	
func _disabled_toggle_select_item_index(active: bool) -> void:
	select_item_index_disabled = active

# Update the current node
func _current_node_changed(current_node):
	get_tree().call_group(&"skipped_before_play", "clear_before_play")
	if current_item_tree != null:
		current_item_tree.set_custom_color(0, Color.GRAY)
	current_item_tree = tree_manager.find_item_by_node(current_node)
	tree_manager.scroll_to_item(current_item_tree, true)
	current_item_tree.set_custom_color(0, Color.LIME_GREEN)
	_current_node = current_node
	_update_pen_settings_from_node(current_node)

func _update_pen_settings_from_node(node: ClassNode):
	if not is_instance_valid(node):
		return
	
	# Only for ClassLeaf
	if node is ClassLeaf:
		var entity = node.entity
		if not is_instance_valid(entity):
			return
		
		# Updates color picker and thickness to its actual value
		if entity is LineEntity:
			_set_colorpicker_silently(entity.pen_color)
			_set_thickness_silently(entity.pen_thickness)
			
			# Emits the actual color so it keeps writing were it was left
			_bus.pen_color_changed.emit(entity.pen_color)
			_bus.pen_thickness_changed.emit(entity.pen_thickness)
		
		# For the PenColorEntity and ThicknessEntity we want to update too
		# because the drawing starts from here on
		elif entity is PenColorEntity:
			_set_colorpicker_silently(entity.color)
			
			_bus.pen_color_changed.emit(entity.color)
			
		elif entity is PenThicknessEntity:
			_set_thickness_silently(entity.thickness)
			
			_bus.pen_thickness_changed.emit(entity.thickness)

## Sets the color without adding a new node
func _set_colorpicker_silently(color: Color):
	if not is_instance_valid(pen_color_picker):
		return
	
	# Disconnects color picker temporarily to avoid loops
	if pen_color_picker.is_connected("color_changed", _on_color_picker_changed):
		pen_color_picker.disconnect("color_changed", _on_color_picker_changed)
	
	# Updates the color
	pen_color_picker.color = color
	
	# Updates the label
	if pen_color_label:
		pen_color_label.text = "Color: #%s" % color.to_html()
	
	# Reconnects the color picker
	pen_color_picker.color_changed.connect(_on_color_picker_changed)

## Sets a value for the slider without adding a new node
func _set_thickness_silently(value: float):
	if not is_instance_valid(pen_thickness_slider):
		return
	
	# Stops the timer if active
	if _pen_thickness_timer.time_left > 0:
		_pen_thickness_timer.stop()
	
	# Disconnects the slider temporarily
	if pen_thickness_slider.is_connected("value_changed", _on_thickness_slider_changed):
		pen_thickness_slider.disconnect("value_changed", _on_thickness_slider_changed)
	
	# Updates value
	pen_thickness_slider.value = value
	
	# Updates label
	if pen_thickness_label:
		pen_thickness_label.text = "Thickness: %.1f" % value
	
	# Reconnects
	pen_thickness_slider.value_changed.connect(_on_thickness_slider_changed)

# Show or hide items from a group if it is collapsed
func _on_item_collapse(item: TreeItem) -> void:
	if item == current_item_tree:
		_execute_after_rendering()

# Emit class selected nodes from panel items
func _on_multi_selected(item: TreeItem, column: int, selected: bool):
	if select_item_index_disabled:
		return
	var node = item.get_metadata(0)
	_bus.class_node_selected.emit(node, selected)

# Show or hide all the children of a group if it is collapsed
func _execute_after_rendering():
	if select_item_index_disabled:
		return
	if _current_node._node_controller is GroupController and current_item_tree.collapsed:
		_current_node._node_controller.skip_all_children()
		_bus.show_outlines.emit()
	else:
		get_tree().call_group(&"skipped_before_play", "clear_before_play")
		_bus.clear_outlines.emit()

func _clear_selection():
	tree_manager.deselect_all()

func _on_pen_thickness_changed():
	if not is_instance_valid(resources_class):
		resources_class = PersistenceEditor.resources_class
	if not is_instance_valid(resources_class):
		printerr("ERROR: Cannot access resources_class in _on_pen_thickness_changed")
		return

	_bus.pen_thickness_changed.emit(_pending_pen_thickness)
	
	var thickness_entity := PenThicknessEntity.new()
	thickness_entity.thickness = _pending_pen_thickness
	
	_bus.add_class_leaf_entity.emit(thickness_entity, [])

func _on_pen_color_changed(color: Color) -> void:
	if not is_instance_valid(resources_class):
		resources_class = PersistenceEditor.resources_class
		if not is_instance_valid(resources_class):
			printerr("ERROR: Cannot access resources_class in _on_pen_color_changed")
			return
	
	_bus.pen_color_changed.emit(color)
		
	var color_entity := PenColorEntity.new()
	color_entity.color = color
	
	_bus.add_class_leaf_entity.emit(color_entity, [])

func _on_color_picker_changed(color: Color) -> void:
	_pending_pen_color = color
	_pen_color_changed = true
	_pen_color_changed_first = true
	
func _on_color_picker_closed() -> void:
	if _pen_color_changed:
		_on_pen_color_changed(_pending_pen_color)
		_pen_color_changed = false
	
func _on_thickness_slider_changed(value: float) -> void:
	_pending_pen_thickness = value
	_pen_thickness_timer.start()
	_pen_thickness_changed_first = true

func _on_pen_started_drawing() -> void:
	if _first_stroke:
		if _pen_color_changed_first and !_pen_thickness_changed_first:
			var thickness_entity := PenThicknessEntity.new()
			thickness_entity.thickness = _pending_pen_thickness
			_bus.add_class_leaf_entity.emit(thickness_entity, [])
		
		if _pen_thickness_changed_first and !_pen_color_changed_first:
			var color_entity := PenColorEntity.new()
			color_entity.color = pen_color_picker.color
			_bus.add_class_leaf_entity.emit(color_entity, [])
		
		if !_pen_thickness_changed_first and !_pen_color_changed_first:
			var color_entity := PenColorEntity.new()
			color_entity.color = pen_color_picker.color
			_bus.add_class_leaf_entity.emit(color_entity, [])
			
			var thickness_entity := PenThicknessEntity.new()
			thickness_entity.thickness = _pending_pen_thickness
			_bus.add_class_leaf_entity.emit(thickness_entity, [])
		
		_first_stroke = false
		
#endregion
