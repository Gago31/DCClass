class_name ClearWidget
extends OperationWidget

## Widget for a clear operation. 
##
## Clears all previous elements from its parent group.


func _on_started_playing() -> void:
	WhiteboardManager.clear_until(self)
	finish_playing()

func _on_skip() -> void:
	_on_started_playing()

func _on_unpaused() -> void:
	finish_playing()

func get_entity() -> ClearEntity:
	return entity as ClearEntity
