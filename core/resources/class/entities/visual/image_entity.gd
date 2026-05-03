# 1. class name: fill the class name
class_name ImageEntity
extends VisualEntity

# 2. docs: use docstring (##) to generate docs for this file
## An [Entity] that holds a reference to an image file.

# 3. signals: define signals here

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here
@export_file() var image_path: String
# 7. public variables: define all public variables here

# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here
func get_class_name() -> String:
	return "ImageEntity"

func get_editor_name() -> String:
	return "Image: " + image_path

func get_widget() -> PackedScene:
	return preload("uid://bfyhdkl1lp68k")

#func serialize() -> Dictionary:
	#return {
		#"entity_id": entity_id,
		#"entity_type": get_class_name(),
		#"image_path": image_path
	#}

#func load_data(data: Dictionary) -> void:
	#image_path = data["image_path"]
	#duration = 0.0

#func save_resource(path: String) -> String:
	#var filename = path.split("/")[-1]
	#var extension = filename.split(".")[-1]
	#var raw_name = filename.replace("." + extension, "")
	#var salted_name = raw_name + str(Time.get_unix_time_from_system()) + "." + extension
	#
	#var path_tmp: String = "user://tmp/class_editor/"
	#var path_images: String = "resources/images/"
#
	#var full_path = path_tmp + path_images
	#if !DirAccess.dir_exists_absolute(full_path):
		#DirAccess.make_dir_recursive_absolute(full_path)
	#DirAccess.copy_absolute(path, full_path + salted_name)
	#return path_images + salted_name

func get_resource_path() -> String:
	return "images/%s" % image_path

func compute_duration() -> float:
	return 0.0 

func config_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, get_editor_name())

# 13. private methods: define all private methods here, use _ as preffix

# 14. subclasses: define all subclasses here
