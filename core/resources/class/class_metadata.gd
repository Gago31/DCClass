class_name ClassMetadata
extends Resource

## Metadata of a class
##
## It contains data of the class, like name, description and course.
## It also contains the name and description of the author.
## Lastly, it contains data of the class file, like version, date and license.

## DCClass version
@export_storage var app_version: String:
	get:
		return "1.0.0"

## Class name
@export var name: String
## A brief description of the class
@export_multiline var description: String
## Course name and code
@export var course: String

@export_group("Author", "author_")
## Author(s) name(s)
@export var author_name: String
## Author(s) description, here you can put a contact link and a profile page
@export_multiline var author_description: String

@export_group("File")
## The file version, it should increase with every new release
@export var file_version: String
## Date of the last file modification
@export var date: Date
## Relative path to license file
@export_file var license: String


func _init() -> void:
	if not date:
		date = Date.new()

func serialize() -> Dictionary:
	return {
		"name": name,
		"description": description,
		"course": course,
		"author_name": author_name,
		"author_description": author_description,
		"file_version": file_version,
		"date": date.serialize(),
		"license": license,
	}

static func deserialize(data: Dictionary) -> ClassMetadata:
	var instance: ClassMetadata = ClassMetadata.new()
	instance.name = data["name"]
	instance.description = data["description"]
	instance.course = data["course"]
	instance.author_name = data["author_name"]
	instance.author_description = data["author_description"]
	instance.file_version = data["file_version"]
	instance.date = Date.deserialize(data["date"])
	instance.license = data["license"]
	return instance
