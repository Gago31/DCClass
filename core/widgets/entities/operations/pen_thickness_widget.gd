class_name PenThicknessWidget
extends OperationWidget


func _on_started_playing() -> void:
	WhiteboardManager.set_pen_thickness(get_entity().thickness)
	finish_playing()

func skip_to_end():
	_on_started_playing()

func get_entity() -> PenThicknessEntity:
	return entity as PenThicknessEntity
