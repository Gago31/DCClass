# 1. class name: fill the class name
class_name AudioEntity
extends Entity

# 2. docs: use docstring (##) to generate docs for this file
## An [Entity] that holds the reference to an audio file

# 3. signals: define signals here

signal audio_converted

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here

# The path in the resources folder(Zip or tmp) to the audio file.
@export var audio_path: String

# 7. public variables: define all public variables here

# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here

func _init(path: String = "", audio_duration: float = 0.0) -> void:
	audio_path = path
	duration = audio_duration

func get_class_name() -> String:
	return "AudioEntity"

func get_editor_name() -> String:
	return "Audio: " + audio_path

func get_widget() -> PackedScene:
	return preload("uid://biha46ac5k722")

func _on_audio_converted(_result: Variant) -> void:
	resource_ready = true
	audio_converted.emit()

func get_resource_path() -> String:
	return "audio/%s" % audio_path

### Returns a dictionary representation of this entity.
#func serialize() -> Dictionary:
	#return {
		#"entity_id": entity_id,
		#"entity_type": get_class_name()
	#}
#
### Returns a new instance of this entity type from the given dictionary(.json).
#static func deserialize(data: Dictionary) -> Entity:
	#assert(CustomClassDB.class_exists(data["entity_type"]), "Entity type does not exist: " + data["entity_type"])
	#var instance = CustomClassDB.instantiate(data["entity_type"])
	#instance.entity_id = data["entity_id"]
	#instance.load_data(data)
	#return instance

### Loads data from a dictionary into this entity.
#func load_data(_data: Dictionary) -> void:
	#pass

### Returns a temporary copy of this entity.
#func copy_tmp() -> Entity:
	#var new_entity: Entity = CustomClassDB.instantiate(get_class_name())
	#new_entity.load_data(serialize())
	#return new_entity

# Deletes this entity.

# Serialize to a dictionary format(.json) for saving.
#func serialize() -> Dictionary:
	#return {
		#"entity_id": entity_id,
		#"entity_type": get_class_name(),
		#"audio_path": audio_path,
		#"duration": duration
	#}
#
## Load data from a dictionary format(.json) to resource(AudioEntity).
#func load_data(data: Dictionary) -> void:
	#audio_path = data["audio_path"]
	#duration = data["duration"]

# Delete this AudioEntity and its associated audio file.
#func self_delete() -> void:
	#var path_tmp: String = "user://tmp/class_editor/"
#
	#if audio_path != "":
		#DirAccess.remove_absolute(path_tmp + audio_path)
	#audio_path = ""

# Copy this AudioEntity to a temporary AudioEntity.
#func copy_tmp() -> Entity:
	#var new_entity: Entity = CustomClassDB.instantiate(get_class_name())
	#new_entity.load_data(serialize())
	#var path_tmp: String = "user://tmp/class_editor/"
	#var _path_tmp: String = "tmp/"
	#var path_audio: String = "resources/audio/"
	#var audio_path_tmp: String = path_audio + str(entity_id) + ".ogg"
	#if audio_path != "":
		#if FileAccess.file_exists(path_tmp + audio_path):
			#if !DirAccess.dir_exists_absolute(path_tmp + _path_tmp + path_audio):
				#DirAccess.make_dir_recursive_absolute(path_tmp + _path_tmp + path_audio)
			#DirAccess.copy_absolute(path_tmp + audio_path, path_tmp + _path_tmp + audio_path_tmp)
		#else:
			#push_error("Audio file does not exist: " + audio_path)
	#new_entity.audio_path = audio_path_tmp
	#return new_entity


# Convert the temporary AudioEntity to a persistent AudioEntity.
# In this process the temporary audio file is moved to the persistent audio folder.
#func tmp_to_persistent() -> void:
	#var path_tmp: String = "user://tmp/class_editor/"
	#var _path_tmp: String = "tmp/"
	#var path_audio: String = "resources/audio/"
	#var path_persistent: String = path_audio + str(entity_id) + ".ogg"
	#if audio_path != "":
		#if FileAccess.file_exists(path_tmp + _path_tmp + audio_path):
			#DirAccess.rename_absolute(path_tmp + _path_tmp + audio_path, path_tmp + path_persistent)
			#audio_path = path_persistent
		#else:
			#push_error("Audio file does not exist: " + path_tmp + audio_path)
	#audio_path = path_persistent
	
func config_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, "Audio: %s" % audio_path)
	var minutes := int(duration) / 60
	var seconds := int(duration) % 60
	var time_string := "%02d:%02d" % [minutes, seconds]
	item.set_text(1, "Duration: %s" % time_string)
	#item.set_text(1, "%d" % duration)

# 13. private methods: define all private methods here, use _ as preffix

# 14. subclasses: define all subclasses here
