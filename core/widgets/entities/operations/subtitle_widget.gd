class_name SubtitleWidget
extends OperationWidget


func _on_started_playing() -> void:
	WhiteboardManager.update_subtitles(entity.text)
	finish_playing()

func _on_skip() -> void:
	print("Skip subtitles: " + entity.text)
	WhiteboardManager.update_subtitles(entity.text)

func _on_unpaused() -> void:
	finish_playing()

func get_entity() -> SubtitleEntity:
	return entity as SubtitleEntity
