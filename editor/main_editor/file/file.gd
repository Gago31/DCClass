class_name FileEditor
extends Control


signal updated

@export var metadata: ClassMetadata
#var editor_signals: EditorEventBus
#var resources_class: ResourcesClassEditor
@onready var name_input: LineEdit = %Name
@onready var description: TextEdit = %Description
@onready var course: LineEdit = %Course
@onready var author_name: LineEdit = %AuthorName
@onready var author_description: TextEdit = %AuthorDescription
@onready var version: LineEdit = %Version
@onready var date: LineEdit = %Date
@onready var license: LineEdit = %License
@onready var save_button: Button = %SaveButton
@onready var export_button: Button = %ExportButton
@onready var export_file_dialog: FileDialog = %ExportFileDialog

#@onready var btn_export_class: Button = %ExportButton

func _ready():
	metadata = EditorManager.metadata
	_update()

## Update the editor to reflect the current metadata.
func _update():
	if not metadata: return
	# Class Info
	name_input.text = metadata.name
	description.text = metadata.description
	course.text = metadata.course
	# Author info
	author_name.text = metadata.author_name
	author_description.text = metadata.author_description
	# File info
	version.text = metadata.file_version
	date.text = metadata.date.date
	license.text = metadata.license

## Save the metadata to the resource.
func save():
	EditorManager.save()


func _setup_export_dialog() -> void:
	export_file_dialog.filters = ["*.dcc"]
	export_file_dialog.current_file = "export_newclass.dcc"
	export_file_dialog.title = "Save class as…"

## Export the class to a zip file.
func export_class():
	var path: String = "user://tmp/class_editor/"
	var path_index: String = path + "index.json"
	var file := FileAccess.open(path_index, FileAccess.WRITE)
	#file.store_string(JSON.stringify(resources_class.class_index.serialize(), "\t"))
	file.close()
	_setup_export_dialog()
	export_file_dialog.popup()
	var zip_dest: String = await export_file_dialog.file_selected
	if zip_dest.is_empty():
		push_warning("Export error.")
		return
	zip_folder("user://tmp/class_editor/", zip_dest)
	print("Export class path:", zip_dest)


func zip_folder(source_dir: String, zip_path: String) -> Error:
	var zipper := ZIPPacker.new()
	var err := zipper.open(zip_path)
	if err != OK:
		push_error("Can't open the file to write:: %s (Error %d)" % [zip_path, err])
		return err

	_add_folder_to_zip(zipper, source_dir, "")
	zipper.close()
	return OK


func _add_folder_to_zip(zipper: ZIPPacker, current_dir: String, relative_path: String) -> void:
	for file_name in DirAccess.get_files_at(current_dir):
		var file_path := current_dir.path_join(file_name)
		var path_in_zip := relative_path + file_name
		
		var f := FileAccess.open(file_path, FileAccess.READ)
		if f == null:
			push_error("Can't open the file to read: %s" % file_path)
			continue
		var data := f.get_buffer(f.get_length())
		f.close()

		var err_start := zipper.start_file(path_in_zip)
		if err_start != OK:
			push_error("Error Zip: %s (Error %d)" % [path_in_zip, err_start])
			continue

		zipper.write_file(data)
		zipper.close_file()

	for subdir in DirAccess.get_directories_at(current_dir):
		var subdir_path := current_dir.path_join(subdir) + "/"
		var new_relative := relative_path + subdir + "/"

		_add_folder_to_zip(zipper, subdir_path, new_relative)


func _on_name_text_changed(new_text: String) -> void:
	metadata.name = new_text

func _on_description_text_changed() -> void:
	metadata.description = description.text

func _on_course_text_changed(new_text: String) -> void:
	metadata.course = new_text

func _on_author_name_text_changed(new_text: String) -> void:
	metadata.author_name = new_text

func _on_author_description_text_changed() -> void:
	metadata.author_description = author_description.text

func _on_version_text_changed(new_text: String) -> void:
	metadata.file_version = new_text

func _on_date_text_changed(new_text: String) -> void:
	var new_date = Date.new()
	new_date.date = new_text
	metadata.date = new_date

func _on_license_text_changed(new_text: String) -> void:
	metadata.license = new_text
