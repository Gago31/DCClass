class_name PenColorWidget
extends OperationWidget


func setup() -> void:
	WhiteboardManager.set_pen_color(get_entity().color)

func _on_started_playing() -> void:
	#WhiteboardManager.set_pen_color(get_entity().color)
	finish_playing()

func _on_skip() -> void:
	WhiteboardManager.set_pen_color(get_entity().color)

#func _on_reset() -> void:
	#WhiteboardManager.set_pen_color(get_entity().color)

func get_entity() -> PenColorEntity:
	return entity as PenColorEntity
