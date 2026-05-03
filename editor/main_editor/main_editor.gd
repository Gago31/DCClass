extends Control

#@onready var core_signals: CoreEventBus = Engine.get_singleton(&"CoreSignals")
#@onready var editor_signals: EditorEventBus = Engine.get_singleton(&"EditorSignals")

#@onready var resources_class: ResourcesClassEditor = %Resources

@onready var file_editor: FileEditor = %File
@onready var control_panel: EditorUI = %"Control Panel"
@onready var tree_postprocessing: TreePostprocessing = %TreePostprocessing

#@onready var audio_record: ClassAudioRecord = %AudioRecord

var _window_whiteboard: WindowWhiteboard
@export var window_whiteboard: PackedScene

#
#func _enter_tree() -> void:
	#Engine.register_singleton(&"CoreSignals", CoreEventBus.new())
	#Engine.register_singleton(&"EditorSignals", EditorEventBus.new())


func _ready() -> void:
	#PersistenceEditor.core_signals = core_signals
	#PersistenceEditor.editor_signals = editor_signals
	#PersistenceEditor.resources_class = resources_class
	#PersistenceEditor._setup()
	#control_panel._bus.request_detach.connect(_on_request_detach)
	#file_editor._setup()
	control_panel._setup()
	#audio_record._setup()
	#control_panel._bus.audio_record.connect(_on_request_audio_record)
	_on_request_detach()
	_on_tree_updated()


func _on_request_detach() -> void:
	if _window_whiteboard and is_instance_valid(_window_whiteboard):
		return
	_window_whiteboard = window_whiteboard.instantiate() as WindowWhiteboard
	get_tree().root.add_child(_window_whiteboard)
	_window_whiteboard.close_requested.connect(_on_window_close_requested)
	await get_tree().process_frame
	#PersistenceEditor._epilog()
	#editor_signals.seek_node.emit(PersistenceEditor.resources_class._current_node)
	

func _on_window_close_requested() -> void:
	if _window_whiteboard:
		_window_whiteboard.queue_free()
		_window_whiteboard = null
		#core_signals.stop_widget.emit()
	#if PersistenceEditor.Status.PLAYING == PersistenceEditor._status:
		#PersistenceEditor._epilog(PersistenceEditor.Status.STOPPED)

#func _on_request_audio_record(active: bool) -> void:
	#audio_record.record()


func _on_tree_updated() -> void:
	tree_postprocessing.postprocess(WhiteboardManager.get_root_widget())
