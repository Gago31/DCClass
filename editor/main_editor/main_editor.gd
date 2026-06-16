extends Control


var _window_whiteboard: WindowWhiteboard
@export var window_whiteboard: PackedScene

@onready var file_editor: FileEditor = %Info
@onready var control_panel: EditorUI = %"Control Panel"
@onready var tree_postprocessing: TreePostprocessing = %TreePostprocessing
@onready var export_file_dialog: FileDialog = %ExportFileDialog


func _ready() -> void:
	control_panel.save_pressed.connect(save)
	control_panel.export_pressed.connect(export_class)
	file_editor.save_pressed.connect(save)
	file_editor.export_pressed.connect(export_class)
	control_panel._setup()
	WhiteboardManager.detach_whiteboard()
	EditorManager._main_ui = self
	#WhiteboardManager.reprocess_tree()
	get_tree().root.size_changed.connect(_on_resize)
	DisplayServer.window_set_min_size(Vector2(800, 400))

func _on_resize() -> void:
	var new_size := get_tree().root.size.max(Vector2(800, 400))
	custom_minimum_size = new_size
	size = new_size
	position = Vector2.ZERO

func _on_window_close_requested() -> void:
	if _window_whiteboard:
		_window_whiteboard.queue_free()
		_window_whiteboard = null

func save():
	EditorManager.save()

func _setup_export_dialog() -> void:
	#export_file_dialog.filters = ["*.dcc"]
	export_file_dialog.current_file = "export_newclass.dcc"
	#export_file_dialog.title = "Save class as…"

## Export the class to a zip file.
func export_class() -> void:
	_setup_export_dialog()
	export_file_dialog.popup()
	var zip_dest: String = await export_file_dialog.file_selected
	if zip_dest.is_empty():
		push_warning("Export error.")
		return
	EditorManager.export_project(zip_dest)
