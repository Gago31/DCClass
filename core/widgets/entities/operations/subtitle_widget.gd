class_name SubtitleWidget
extends Widget


@export var entity: SubtitleEntity


func serialize() -> Dictionary:
	return entity.serialize()

func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	_bus_core.subtitles_updated.emit(entity.text)
	emit_signal("widget_finished")

func reset():
	pass

func stop() -> void:
	skip_to_end()

func skip_to_end() -> void:
	_bus_core.subtitles_updated.emit(entity.text)
	emit_signal("widget_finished")

func clear():
	reset()
	add_to_group(&"widget_cleared")

func unclear():
	skip_to_end()
	remove_from_group(&"widget_cleared")
