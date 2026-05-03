class_name ClassWindowEditor
extends Control


var show_index_tree := false
var class_root: ClassRootWidget
var current_time: float
var final_time: float
var final_time_str: String

var time_slider_drag: bool = false
var was_playing: bool = false
@export var test_class: ClassRoot
@onready var viewport: SubViewport = %SubViewport
@onready var zoom_slider: HSlider = %ZoomSlider
@onready var zoom_button: TextureButton = %ZoomButton
@onready var slide_size: Vector2 = ProjectSettings.get_setting("display/whiteboard/size") as Vector2
@onready var label_time_current: Label = %TimeCurrent
@onready var time_slider: HSlider = %TimeSlider
@onready var debouncer_timer: Timer = %DebouncerTimer
@onready var index_tree: Tree = %IndexTree
@onready var index_tree_panel: PanelContainer = %IndexTreePanel

@onready var stop_button: Button = %StopButton

@onready var play_icon: Texture2D = get_theme_icon("play", stop_button.theme_type_variation)
@onready var pause_icon: Texture2D = get_theme_icon("pause", stop_button.theme_type_variation)
@onready var subtitles: RichTextLabel = %Subtitles
@onready var whiteboard: WhiteboardInputController = %Whiteboard
@onready var camera: ClassCameraEditor = %Camera2D

var is_stopped: bool = true
# This set the node that will be used as the main node for the whiteboard.
# In this case, it is "visual_widgets" node.
func set_class_node(node: Node) -> void:
	node.reparent(viewport)
	viewport.move_child(node, 0)

func build_class_tree(root: ClassRoot) -> void:
	class_root = root.get_widget().instantiate() as ClassRootWidget
	class_root.started_playing.connect(_update_play_button)
	class_root.paused.connect(_update_play_button)
	class_root.resumed.connect(_update_play_button)
	class_root.finished_playing.connect(_update_play_button)
	class_root.set_class_node(root)
	viewport.add_child(class_root)
	class_root.setup()

func build_index_tree(root: ClassRoot) -> void:
	_build_index_node(root, null)

func _build_index_node(node: ClassNode, parent: TreeItem) -> void:
	if node.is_leaf(): return
	var item := index_tree.create_item(parent)
	var group_node := node as ClassGroup
	#var widget := WhiteboardManager.search_widget_by_class_node(group_node)
	#widget.started_playing.connect(_set_current_item.bind(item, true))
	#widget.resumed.connect(_set_current_item.bind(item, true))
	#widget.finished_playing.connect(_set_current_item.bind(item, true))
	item.set_text(0, group_node._name)
	for child in group_node.children:
		_build_index_node(child, item)

func _update_zoom_slider_value() -> void:
	#if !is_instance_valid(ClassUIEditor.context) or !is_instance_valid(ClassUIEditor.context.camera):
		#return
	#var value: float = ClassUIEditor.context.camera.zoom.x
	var value: float = camera.zoom.x
	zoom_slider.set_value_no_signal(value)

func _zoom_slider_value_selected(value: float) -> void:
	#if !is_instance_valid(ClassUIEditor.context) or !is_instance_valid(ClassUIEditor.context.camera):
		#return
	#ClassUIEditor.context.camera.zoom = Vector2(value, value)
	camera.zoom = Vector2(value, value)
	#ClassUIEditor.context.camera.update_grid_visibility()
	camera.update_grid_visibility()

func _zoom_reset() -> void:
	#if !is_instance_valid(ClassUIEditor.context) or !is_instance_valid(ClassUIEditor.context.camera):
		#return
	var viewport_size := viewport.size
	var zoom := minf(viewport_size.x / slide_size.x, viewport_size.y / slide_size.y)
	#ClassUIEditor.context.camera.interpolate_zoom(zoom)
	camera.interpolate_zoom(zoom)


# Toggle playback stop button.
# If the button is pressed, it will toggle between playing and stopping.
# When playing, the visual widget will begin 
# When stopped, the current  visual widget will be stopped and show his final state.
func _toggle_playback_stop() -> void:
	if class_root.is_playing():
		#print("pause")
		class_root.pause()
	elif class_root.is_paused() or class_root.is_stopped():
		#print("play")
		class_root.play()
	elif class_root.is_finished():
		#class_root.reset()
		class_root.play()
	
	#if is_stopped:
		#PersistenceEditor._epilog(PersistenceEditor.Status.PLAYING)
		#_bus.seek_play.emit()
		#return
	
	#_bus_core.stop_widget.emit()
	#get_tree().call_group(&"widget_playing", "stop")
	#PersistenceEditor._epilog(PersistenceEditor.Status.STOPPED)

func _update_play_button() -> void:
	stop_button.icon = pause_icon if class_root.is_playing() else play_icon
		
# 0: playing, 1: stopped
# This is used to update the stup_button icon/state.
func _status_playback_stop(active: bool = is_stopped) -> void:
	is_stopped = active
	if is_stopped:
		stop_button.icon = play_icon
		return
	stop_button.icon = pause_icon

# To disable the stop button.
func _disabled_toggle_stop_button(active: bool) -> void:
	stop_button.disabled = active

func _get_time_string(total_seconds: float) -> String:
	var format_str = "%02d:%02d:%02d"
	var sec_f = fmod(total_seconds, 60)
	var min_total = total_seconds / 60
	var min_f = fmod(min_total, 60)
	var hour_f = min_total / 60
	return format_str % [hour_f, min_f, sec_f]

# Setup the time slider and label based on the complete duration of the class.
func _setup_timeline():
	print("setup timeline")
	#final_time = PersistenceEditor.resources_class.root_tree_structure._node_controller._compute_class_duration()
	final_time = class_root.duration
	print(final_time)
	time_slider.max_value = final_time
	#time_slider.value = 0.0
	time_slider.value = class_root.play_time
	final_time_str = _get_time_string(final_time)
	_update_time_control()

# Update the time slider and label based on the current time.
func _update_time_control():
	current_time = class_root.play_time
	time_slider.value = current_time
	var current_time_str = _get_time_string(current_time)
	label_time_current.text = current_time_str + " / " + final_time_str

# Seek the time slider by the current node given.
#func _seek_time_slide(_current_node: ClassNode):
	##current_time = PersistenceEditor.resources_class.root_tree_structure._node_controller._compute_current_time(_current_node._node_controller)
	#_update_time_control()

# Begin to drag the time slider.
func _on_time_slider_drag_started() -> void:
	time_slider_drag = true
	#if PersistenceEditor._status == PersistenceEditor.Status.PLAYING:
		#was_playing = true
	#else:
		#was_playing = false
	#_bus_core.stop_widget.emit()
	#get_tree().call_group(&"widget_playing", "stop")
	#PersistenceEditor._epilog(PersistenceEditor.Status.STOPPED)

# Ended to drag the time slider.
func _on_time_slider_drag_ended(value_changed: bool) -> void:
	time_slider_drag = false
	debouncer_timer.start()
	#await debouncer_timer.timeout
	#class_root.seek(time_slider.value)
	#if was_playing:
		##PersistenceEditor._epilog(PersistenceEditor.Status.PLAYING)
		##_bus.seek_play.emit()
		#return

# When the value changed of the time slider, we update the class by the current time.
func _on_time_slider_value_changed(value: float) -> void:
	# We use a debouncer timer to avoid too many updates while dragging.
	if time_slider_drag and debouncer_timer.is_stopped():
		print("Timeline changed")
		debouncer_timer.start()
		

# Trigger when the debouncer timer timeout.
func _on_debouncer_timer_timeout() -> void:
	#_update_timer_slider_by_time()
	print("Seek timer ended")
	class_root.seek(time_slider.value, class_root.is_playing())
	_update_time_control()

# Update the timer slider and the current node by the time slider value.
#func _update_timer_slider_by_time():
	#var seeked_node: NodeController = PersistenceEditor.resources_class.root_tree_structure._node_controller._seek_node_time(time_slider.value)
	#_bus_core.current_node_changed.emit(seeked_node._class_node)
	#_bus.seek_node.emit(seeked_node._class_node)
	#if !time_slider_drag:
		#_seek_time_slide(PersistenceEditor.resources_class._current_node)


func _ready():
	#build_class_tree(test_class)
	#build_index_tree(test_class)
	WhiteboardManager.ui = self
	set_subtitles("")
	build_class_tree(WhiteboardManager.root)
	build_index_tree(WhiteboardManager.root)
	class_root.child_added.connect(_on_tree_modified)
	class_root.playtime_changed.connect(_update_time_control)
	#if !is_instance_valid(ClassUIEditor.context):
		#printerr("ClassUIEditor context is not valid")
	#else:
	get_tree().process_frame.connect(_zoom_reset, CONNECT_ONE_SHOT)
	
	stop_button.pressed.connect(_toggle_playback_stop)
	
	#_bus.disabled_toggle_stop_button.connect(_disabled_toggle_stop_button)
	#_bus.status_playback_stop.connect(_status_playback_stop)
	
	zoom_slider.value_changed.connect(_zoom_slider_value_selected)
	zoom_button.pressed.connect(_zoom_reset)
	
	_setup_timeline() # To set the ti & tf
	#_bus.setup_timeline.connect(_setup_timeline)
	#_bus.seek_time_slide.connect(_seek_time_slide)
	
	
	time_slider.drag_started.connect(_on_time_slider_drag_started)
	time_slider.value_changed.connect(_on_time_slider_value_changed)
	debouncer_timer.timeout.connect(_on_debouncer_timer_timeout)
	time_slider.drag_ended.connect(_on_time_slider_drag_ended)
	
	#_bus.update_timer_slider_by_time.connect(_update_timer_slider_by_time)
	

func _process(_delta: float):
	_update_zoom_slider_value()
	if class_root.is_playing():
		_update_time_control()

func _on_index_button_pressed() -> void:
	show_index_tree = !show_index_tree
	if show_index_tree:
		index_tree_panel.show()
		create_tween().tween_property(
			index_tree_panel, 
			"custom_minimum_size", 
			Vector2(150, 0), 
			0.2
		)
	else:
		var tween := create_tween().tween_property(
			index_tree_panel, 
			"custom_minimum_size", 
			Vector2.ZERO, 
			0.2
		)
		await tween.finished
		index_tree_panel.hide()

func set_subtitles(text: String) -> void:
	subtitles.parse_bbcode(text)

func _set_current_item(item: TreeItem, is_current: bool) -> void:
	item.set_custom_color(0, Color.LIME_GREEN if is_current else Color.GRAY)

func _on_tree_modified() -> void:
	WhiteboardManager.reprocess_tree()
	_setup_timeline()

func _on_visual_widget_selected(widget: VisualEntityWidget, multi_select: bool, unselectable: bool) -> void:
	prints("Selected widget", widget, "multi:", multi_select)
	whiteboard.select_widget(widget, multi_select, unselectable)
