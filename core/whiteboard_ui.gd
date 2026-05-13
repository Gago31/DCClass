class_name WhiteboardUI
extends Control

#var show_index_tree := false
var class_root: ClassRootWidget
var current_time: float
var final_time: float
var final_time_str: String
var time_slider_drag: bool = false
var was_playing: bool = false

@onready var viewport: SubViewport = %SubViewport
@onready var zoom_slider: HSlider = %ZoomSlider
@onready var zoom_button: TextureButton = %ZoomButton
@onready var slide_size: Vector2 = ProjectSettings.get_setting("display/whiteboard/size") as Vector2
@onready var label_time_current: Label = %TimeCurrent
@onready var time_slider: HSlider = %TimeSlider
@onready var debouncer_timer: Timer = %DebouncerTimer
@onready var stop_button: Button = %StopButton
@onready var play_icon: Texture2D = get_theme_icon("play", stop_button.theme_type_variation)
@onready var pause_icon: Texture2D = get_theme_icon("pause", stop_button.theme_type_variation)
@onready var subtitles: RichTextLabel = %Subtitles
@onready var camera: ClassCameraEditor = %Camera2D


func _ready():
	WhiteboardManager.ui = self
	set_subtitles("")
	build_class_tree(WhiteboardManager.root)
	class_root.playtime_changed.connect(_update_time_control)
	get_tree().process_frame.connect(_zoom_reset, CONNECT_ONE_SHOT)
	
	class_root.updated.connect(_on_tree_modified)
	
	stop_button.pressed.connect(_toggle_playback_stop)
	
	zoom_slider.value_changed.connect(_zoom_slider_value_selected)
	zoom_button.pressed.connect(_zoom_reset)
	
	_setup_timeline() # To set the ti & tf

	time_slider.drag_started.connect(_on_time_slider_drag_started)
	time_slider.value_changed.connect(_on_time_slider_value_changed)
	debouncer_timer.timeout.connect(_on_debouncer_timer_timeout)
	time_slider.drag_ended.connect(_on_time_slider_drag_ended)

func _process(_delta: float):
	if class_root.is_playing():
		_update_time_control()

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"camera_zoom_in"):
		zoom_slider.value += 0.1
	elif event.is_action_pressed(&"camera_zoom_out"):
		zoom_slider.value -= 0.1

func build_class_tree(root: ClassRoot) -> void:
	class_root = root.get_widget().instantiate() as ClassRootWidget
	class_root.started_playing.connect(_update_play_button)
	class_root.paused.connect(_update_play_button)
	class_root.resumed.connect(_update_play_button)
	class_root.finished_playing.connect(_update_play_button)
	class_root.set_class_node(root)
	viewport.add_child(class_root)
	class_root.setup()

func _zoom_slider_value_selected(value: float) -> void:
	camera.zoom = Vector2(value, value)
	camera.update_grid_visibility()

func _zoom_reset() -> void:
	var viewport_size := viewport.size
	var zoom := minf(viewport_size.x / slide_size.x, viewport_size.y / slide_size.y)
	camera.interpolate_zoom(zoom)

# Toggle playback stop button.
# If the button is pressed, it will toggle between playing and stopping.
# When playing, the visual widget will begin 
# When stopped, the current  visual widget will be stopped and show his final state.
func _toggle_playback_stop() -> void:
	if class_root.is_playing():
		class_root.pause()
	elif class_root.is_paused() or class_root.is_stopped():
		class_root.play()
	elif class_root.is_finished():
		class_root.play()

func _update_play_button() -> void:
	stop_button.icon = pause_icon if class_root.is_playing() else play_icon

# To disable the stop button.
func _disabled_toggle_stop_button(active: bool) -> void:
	stop_button.disabled = active

# Setup the time slider and label based on the complete duration of the class.
func _setup_timeline():
	print("setup timeline")
	final_time = class_root.end_time
	print(final_time)
	time_slider.max_value = final_time
	time_slider.set_value_no_signal(class_root.play_time)
	final_time_str = TimeString.from_seconds(final_time, false)
	_update_time_control()

# Update the time slider and label based on the current time.
func _update_time_control():
	if time_slider_drag: return
	current_time = class_root.play_time
	time_slider.set_value_no_signal(current_time)
	var current_time_str := TimeString.from_seconds(current_time, false)
	label_time_current.text = current_time_str + " / " + final_time_str

func _on_time_slider_drag_started() -> void:
	time_slider_drag = true

func _on_time_slider_drag_ended(_value_changed: bool) -> void:
	time_slider_drag = false
	_on_debouncer_timer_timeout()
	#debouncer_timer.start()

func _on_time_slider_value_changed(_value: float) -> void:
	if time_slider_drag and debouncer_timer.is_stopped():
		print("Timeline changed")
		debouncer_timer.start()

func _on_debouncer_timer_timeout() -> void:
	print("Seek timer ended")
	class_root.seek(time_slider.value, class_root.is_playing())
	_update_time_control()

func set_subtitles(text: String) -> void:
	subtitles.parse_bbcode(text)

func _set_current_item(item: TreeItem, is_current: bool) -> void:
	item.set_custom_color(0, Color.LIME_GREEN if is_current else Color.GRAY)

func _on_tree_modified() -> void:
	_setup_timeline()
