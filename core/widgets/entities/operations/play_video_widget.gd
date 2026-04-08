class_name PlayVideoWidget
extends Widget


@export var entity: PlayVideoEntity


func serialize() -> Dictionary:
	return entity.serialize()

func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	# TODO: Get video widget from entity video id
	# Call play until function with entity until position
	# if until position is 0 set video duration as until position
	emit_signal("widget_finished")

func compute_duration() -> float:
	# TODO: Get video widget
	# Get current playback position
	# Calculate duration as until_position - playback_position
	return 0.0

func reset():
	pass

func stop() -> void:
	skip_to_end()

func skip_to_end() -> void:
	# TODO: Stop video and seek to until position
	emit_signal("widget_finished")

func clear():
	reset()
	add_to_group(&"widget_cleared")

func unclear():
	skip_to_end()
	remove_from_group(&"widget_cleared")
