extends Control

@export var mobile_screen: PackedScene

@onready var btn_load_class: Button = %ButtonLoad

func _ready():
	btn_load_class.pressed.connect(_select_file)


#region Select File

func _select_file():
	if OS.has_feature("android"):
		print("Android detected. Using Android file picker.")
		_android_dialog()
		return
	if OS.has_feature("web"):
		print("Web detected. Using browser file picker.")
		return
	if DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG):
		_native_dialog()
		print("Native dialog support detected. Using native file picker.")
		return
	print("No custom dialog support detected. Using built-in file picker.")
#endregion

#region Native Seleccionando Archivo
func _native_dialog():
	DisplayServer.file_dialog_show("Open File", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["*.dcc"], _on_native_dialog_file_selected)

func _on_native_dialog_file_selected(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int) -> void:
	if status == false:
		return
	var path := selected_paths[0]
	_on_file_selected(path)
#endregion

#region Android
func _android_dialog():
	if Engine.has_singleton("GodotFilePicker"):
		var picker = Engine.get_singleton("GodotFilePicker")
		if not picker.file_picked.is_connected(_on_android_file_selected):
			picker.file_picked.connect(_on_android_file_selected)
		picker.openFilePicker("*/*")
	else:
		printerr("GodotFilePicker singleton not found")
		return

func _on_android_file_selected(path: String, _mime_type: String) -> void:
	_on_file_selected(path)
#endregion

#region Process file
func _on_file_selected(path: String) -> void:
	if not path.ends_with(".dcc"):
		printerr("Invalid file type: ", path)
		return
	#PersistenceMobile.file_path = path
	#print("Selected file: ", PersistenceMobile.file_path)
	
	get_tree().change_scene_to_packed(mobile_screen)
#endregion
