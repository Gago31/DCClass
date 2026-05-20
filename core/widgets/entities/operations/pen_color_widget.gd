class_name PenColorWidget
extends OperationWidget

## Widget that represents a color change for the whiteboard's pen.


func setup() -> void:
	WhiteboardManager.set_pen_color(get_entity().color)

func _on_started_playing() -> void:
	finish_playing()

func _on_skip() -> void:
	WhiteboardManager.set_pen_color(get_entity().color)

func get_entity() -> PenColorEntity:
	return entity as PenColorEntity
