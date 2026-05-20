class_name PenThicknessWidget
extends OperationWidget

## Widget that represents a size change for the whiteboard's pen.


func setup() -> void:
	WhiteboardManager.set_pen_thickness(get_entity().thickness)

func _on_started_playing() -> void:
	finish_playing()

func _on_skip() -> void:
	WhiteboardManager.set_pen_thickness(get_entity().thickness)

func get_entity() -> PenThicknessEntity:
	return entity as PenThicknessEntity
