class_name FileEditor
extends Control


signal updated

@export var metadata: ClassMetadata
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
func export_class() -> void:
	_setup_export_dialog()
	export_file_dialog.popup()
	var zip_dest: String = await export_file_dialog.file_selected
	if zip_dest.is_empty():
		push_warning("Export error.")
		return
	EditorManager.export_project(zip_dest)

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
