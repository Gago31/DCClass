extends Control

@export var editor_screen: PackedScene

@onready var btn_create_class: Button = %ButtonCreate
@onready var btn_load_class: Button = %ButtonLoad
@onready var select_file_dialog: FileDialog = %SelectFileDialog
@onready var create_project_dialog: FileDialog = %CreateProjectDialog
@onready var create_error_dialog: AcceptDialog = %CreateErrorDialog
@onready var load_project_dialog: FileDialog = %LoadProjectDialog
@onready var load_error_dialog: AcceptDialog = %LoadErrorDialog

func _ready():
	btn_create_class.pressed.connect(_create_class)
	btn_load_class.pressed.connect(_select_file)


#region Select File

func _select_file():
	if OS.has_feature("android"):
		print("Android detected. Using Android file picker.")
		return
	if OS.has_feature("web"):
		print("Web detected. Using browser file picker.")
	print("No custom dialog support detected. Using built-in file picker or native file picker.")
	_native_dialog()
#endregion

#region Native Seleccionando Archivo


func _native_dialog():
	select_file_dialog.popup()
	#var file_path: String = await select_file_dialog.file_selected
	#_on_file_selected(file_path)

#region Process file
func _on_file_selected(path: String) -> void:
	if not path.ends_with(".dcc"):
		printerr("Invalid file type: ", path)
		return
	#PersistenceEditor.file_path = path
	#print("Selected file: ", PersistenceEditor.file_path)
	
	get_tree().change_scene_to_packed(editor_screen)
#endregion

#region Create Class
# Default class for new classes
#const DEFAULT_CLASS_PATH: String = "user://editor/utils/new_class.dcc"
func _create_class():
	#PersistenceEditor.file_path = DEFAULT_CLASS_PATH
	#print("Selected file: ", PersistenceEditor.file_path)
	create_project_dialog.popup()

func _on_create_project_dialog_dir_selected(dir: String) -> void:
	var dir_access := DirAccess.open(dir)
	dir_access.include_hidden = true
	var directories := dir_access.get_directories()
	var files := dir_access.get_files()
	var valid_dir := files.is_empty() and directories.is_empty()
	if not valid_dir:
		create_error_dialog.popup()
		return
	EditorManager.create_project(dir)
	get_tree().change_scene_to_packed(editor_screen)

#endregion

func _on_button_load_project_pressed() -> void:
	load_project_dialog.popup()

func _on_load_project_dialog_dir_selected(dir: String) -> void:
	var err := EditorManager.load_project(dir)
	if err != OK:
		load_error_dialog.popup()
		return
	get_tree().change_scene_to_packed(editor_screen)
