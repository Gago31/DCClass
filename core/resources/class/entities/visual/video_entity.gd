# 1. class name: fill the class name
class_name VideoEntity
extends VisualEntity

# 2. docs: use docstring (##) to generate docs for this file
## An [Entity] that holds a reference to a video file.

# 3. signals: define signals here
#signal conversion_started
signal conversion_finished(err: bool)

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here
@export var video_path: String
var input_video_path: String = ""
var conversion_thread := Thread.new()
# 7. public variables: define all public variables here

# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here
func get_class_name() -> String:
	return "VideoEntity"

func get_editor_name() -> String:
	return "Video: " + video_path

func get_widget() -> PackedScene:
	return preload("uid://cqqmunsul4k5f")

#TODO: change behavior depending on wether we are on editor or player
func get_video_path() -> String:
	return "%s/video/%s" % [EditorManager.get_assets_path(), video_path]

func get_resource_path() -> String:
	return "video/%s" % video_path

#func serialize() -> Dictionary:
	#return {
		#"entity_id": entity_id,
		#"entity_type": get_class_name(),
		#"video_path": video_path
	#}

#func load_data(data: Dictionary) -> void:
	#video_path = data["video_path"]
	#duration = 0.0

#func set_input_file_path(value: String) -> void:
	#input_video_path = value

#func save_resource(path: String) -> String:
	#var filename = path.split("/")[-1]
	#var extension = filename.split(".")[-1]
	#var raw_name = filename.replace("." + extension, "")
	#var salted_name = raw_name + str(Time.get_unix_time_from_system()) + "." + extension
	#
	#var path_tmp: String = "user://tmp/class_editor/"
	#var path_videos: String = "resources/videos/"
#
	#var full_path = path_tmp + path_videos
	#if !DirAccess.dir_exists_absolute(full_path):
		#DirAccess.make_dir_recursive_absolute(full_path)
	#DirAccess.copy_absolute(path, full_path + salted_name)
	##return path_videos + salted_name
	#return full_path + salted_name

func compute_duration() -> float:
	return 0.0 

func _on_video_converted(_result: Variant, _path: String) -> void:
	#var tmp_path := save_resource(path)
	conversion_finished.emit(true)

func config_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, get_editor_name())

# 13. private methods: define all private methods here, use _ as preffix

# 14. subclasses: define all subclasses here
