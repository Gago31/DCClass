class_name PenThicknessWidget
extends OperationWidget


func setup() -> void:
	WhiteboardManager.set_pen_thickness(get_entity().thickness)

func _on_started_playing() -> void:
	#WhiteboardManager.set_pen_thickness(get_entity().thickness)
	finish_playing()

func _on_skip() -> void:
	WhiteboardManager.set_pen_thickness(get_entity().thickness)
#
#func _on_reset() -> void:
	#WhiteboardManager.set_pen_thickness(get_entity().thickness)

func get_entity() -> PenThicknessEntity:
	return entity as PenThicknessEntity
