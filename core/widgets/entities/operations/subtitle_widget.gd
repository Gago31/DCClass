class_name SubtitleWidget
extends OperationWidget


func _on_started_playing() -> void:
	WhiteboardManager.update_subtitles(get_entity().text)
	finish_playing()

func _on_skip() -> void:
	print("Skip subtitles: " + get_entity().text)
	WhiteboardManager.update_subtitles(get_entity().text)

func _on_unpaused() -> void:
	finish_playing()

func get_entity() -> SubtitleEntity:
	return entity as SubtitleEntity

func _on_entity_updated() -> void:
	super._on_entity_updated()
	WhiteboardManager.update_subtitles(get_entity().text)
