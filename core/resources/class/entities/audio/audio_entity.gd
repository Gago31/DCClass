class_name AudioEntity
extends Entity

## An [Entity] that holds the reference to an audio file


## Emitted when the audio file finished converting. Used in the editor.
signal audio_converted

## The name of the audio file for this entity.
@export var audio_path: String


func _init(path: String = "", audio_duration: float = 0.0) -> void:
	audio_path = path
	duration = audio_duration

func get_class_name() -> String:
	return "AudioEntity"

func get_editor_name() -> String:
	return "Audio: " + audio_path

func get_widget() -> PackedScene:
	return load("uid://biha46ac5k722") as PackedScene

func config_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, "Audio: %s" % audio_path)
	var time_string := TimeString.from_seconds(duration)
	item.set_text(1, "Duration: %s" % time_string)

func _on_audio_converted(_result: Variant) -> void:
	print("Audio converted")
	audio_converted.emit()
