class_name ClassWindowEditor
extends WhiteboardUI


#@export var test_class: ClassRoot

#var show_index_tree := false
#var class_root: ClassRootWidget
#var current_time: float
#var final_time: float
#var final_time_str: String
#var time_slider_drag: bool = false
#var was_playing: bool = false

#@onready var viewport: SubViewport = %SubViewport
#@onready var zoom_slider: HSlider = %ZoomSlider
#@onready var zoom_button: TextureButton = %ZoomButton
#@onready var slide_size: Vector2 = ProjectSettings.get_setting("display/whiteboard/size") as Vector2
#@onready var label_time_current: Label = %TimeCurrent
#@onready var time_slider: HSlider = %TimeSlider
#@onready var debouncer_timer: Timer = %DebouncerTimer
#@onready var index_tree: Tree = %IndexTree
#@onready var index_tree_panel: PanelContainer = %IndexTreePanel
#@onready var stop_button: Button = %StopButton
#@onready var play_icon: Texture2D = get_theme_icon("play", stop_button.theme_type_variation)
#@onready var pause_icon: Texture2D = get_theme_icon("pause", stop_button.theme_type_variation)
#@onready var subtitles: RichTextLabel = %Subtitles
##@onready var whiteboard: WhiteboardInputController = %Whiteboard
#@onready var camera: ClassCameraEditor = %Camera2D


func _ready():
	super._ready()
	#build_class_tree(test_class)
	#build_index_tree(test_class)
	#WhiteboardManager.ui = self
	#set_subtitles("")
	#build_class_tree(WhiteboardManager.root)
	class_root.child_added.connect(_on_tree_modified)
	#class_root.updated.connect(_on_tree_modified)
	#class_root.playtime_changed.connect(_update_time_control)
	#get_tree().process_frame.connect(_zoom_reset, CONNECT_ONE_SHOT)
	
	#stop_button.pressed.connect(_toggle_playback_stop)
	
	#zoom_slider.value_changed.connect(_zoom_slider_value_selected)
	#zoom_button.pressed.connect(_zoom_reset)
	
	#_setup_timeline() # To set the ti & tf

	#time_slider.drag_started.connect(_on_time_slider_drag_started)
	#time_slider.value_changed.connect(_on_time_slider_value_changed)
	#debouncer_timer.timeout.connect(_on_debouncer_timer_timeout)
	#time_slider.drag_ended.connect(_on_time_slider_drag_ended)

#func _on_tree_modified() -> void:
	#_setup_timeline()
