class_name WaitWidget
extends EntityWidget


func get_entity() -> WaitEntity:
	return entity as WaitEntity

func _calculate_duration() -> float:
	return get_entity().duration

func _while_playing(delta: float) -> void:
	if play_time >= duration:
		finish_playing()
