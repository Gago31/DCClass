extends Control

@export var whiteboard: PackedScene

@onready var select_file_dialog: FileDialog = %SelectFileDialog


func _ready() -> void:
	ClassResourceLoader.is_editor = false

func _select_file():
	select_file_dialog.popup()

func _on_file_selected(path: String) -> void:
	if not path.ends_with(".dcc"):
		printerr("Invalid file type: ", path)
		return
	ClassResourceLoader.is_editor = false
	ClassResourceLoader.open_dcc_file(path)
	WhiteboardManager.root = ClassResourceLoader.get_class_tree()
	WhiteboardManager.metadata = ClassResourceLoader.get_class_metadata()
	get_tree().change_scene_to_packed(whiteboard)
