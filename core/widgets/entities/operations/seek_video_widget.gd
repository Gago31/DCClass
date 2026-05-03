class_name SeekVideoWidget
extends OperationWidget


var video_entity: VideoEntity
var video_widget: VideoWidget


func setup() -> void:
	video_entity = get_entity().entity as VideoEntity
	get_entity().reference_set.connect(_on_reference_changed)

func _on_started_playing() -> void:
	video_widget = WhiteboardManager.search_widget_by_entity(video_entity) as VideoWidget
	if not video_widget: 
		print("No widget lmao")
		return
	video_widget.seek_video(get_entity().seek_position)
	finish_playing()

func compute_duration() -> float:
	return 0.0

func _on_skip() -> void:
	video_widget = WhiteboardManager.search_widget_by_entity(video_entity) as VideoWidget
	if not video_widget: return
	video_widget.seek_video(get_entity().seek_position)

func clear():
	reset()

func unclear():
	jump_to_end()

func get_entity() -> SeekVideoEntity:
	return entity as SeekVideoEntity

func _on_reference_changed() -> void:
	video_entity = get_entity().entity as VideoEntity

func _on_target_reached() -> void:
	finished_playing.emit()
