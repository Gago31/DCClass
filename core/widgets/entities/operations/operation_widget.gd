@abstract
class_name OperationWidget
extends EntityWidget


#func _on_skip() -> void:
	#_on_started_playing()

#func _on_reset() -> void:
	#hide()

func _calculate_duration() -> float:
	return 0.0
