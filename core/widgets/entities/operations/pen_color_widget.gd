class_name PenColorWidget
extends OperationWidget


func _on_started_playing() -> void:
	WhiteboardManager.set_pen_color(get_entity().color)
	finish_playing()

func skip_to_end():
	_on_started_playing()

func get_entity() -> PenColorEntity:
	return entity as PenColorEntity
