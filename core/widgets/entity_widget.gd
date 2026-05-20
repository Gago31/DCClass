@abstract
class_name EntityWidget
extends Widget

## The way in which this node should be played. 
@export var play_mode: PlayMode

## The widget's associated [Entity].
var entity: Entity:
	get=get_entity, set=set_entity

## Returns the widget's entity. You should override it and specify the
## return type to get accurate code completion and static typing.
@abstract
func get_entity() -> Entity;

func set_entity(value: Entity) -> void:
	entity = value
	entity.updated.connect(_on_entity_updated)

func get_play_mode() -> PlayMode:
	return play_mode

func search_widget_by_entity(value: Entity) -> EntityWidget:
	if get_entity() == value:
		return self
	return null

func play(speed: float = 1.0) -> void:
	if get_play_mode() == PlayMode.SYNC:
		var sync_speed := duration / (end_time - start_time)
		speed *= sync_speed
	super.play(speed)

func _on_entity_updated() -> void:
	duration = -1.0
	updated.emit()
