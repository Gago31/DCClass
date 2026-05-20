class_name PausePlaybackWidget
extends OperationWidget

## Widget that represents a forced pause in the class.


func _on_started_playing() -> void:
	WhiteboardManager.set_playing(false)

func _on_unpaused() -> void:
	finish_playing()

func get_entity() -> PausePlaybackEntity:
	return entity as PausePlaybackEntity
