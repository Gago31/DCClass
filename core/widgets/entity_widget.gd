@abstract
class_name EntityWidget
extends Widget

## The way in which this node should be played. 
@export var play_mode: PlayMode
var entity: Entity:
	get=get_entity, set=set_entity

@abstract
func get_entity() -> Entity;

func set_entity(value: Entity) -> void:
	entity = value

func get_play_mode() -> PlayMode:
	return play_mode

func search_widget_by_entity(value: Entity) -> Widget:
	if get_entity() == value:
		return self
	return null

func play(speed: float = 1.0) -> void:
	if get_play_mode() == PlayMode.SYNC:
		var sync_speed := duration / (end_time - start_time)
		speed *= sync_speed
	super.play(speed)
