class_name PlayVideoWidget
extends OperationWidget


var video_entity: VideoEntity
var video_widget: VideoWidget
var _time_changed := false

func setup() -> void:
	video_entity = get_entity().entity as VideoEntity
	get_entity().reference_set.connect(_on_reference_changed)
	await get_tree().process_frame
	video_widget = WhiteboardManager.search_widget_by_entity(video_entity) as VideoWidget

func _on_started_playing() -> void:
	#video_widget = WhiteboardManager.search_widget_by_entity(video_entity) as VideoWidget
	if not video_widget: return
	# TODO: Get video widget from entity video id
	print("a")
	_connect_to_widget()
	video_widget.play_video_until(get_entity().until_position)
	# Call play until function with entity until position
	# if until position is 0 set video duration as until position

func _connect_to_widget() -> void:
	if not video_widget.reached_target_time.is_connected(_on_target_reached):
		video_widget.reached_target_time.connect(_on_target_reached, CONNECT_ONE_SHOT)

func _on_unpaused() -> void:
	if _time_changed:
		video_widget.seek_video_deferred(get_entity().until_position - play_time)
	video_widget.play_video()

func _on_paused() -> void:
	#video_widget = WhiteboardManager.search_widget_by_entity(video_entity) as VideoWidget
	if not video_widget: return
	video_widget.pause_video()

func _calculate_duration() -> float:
	# TODO: Get video widget
	# Get current playback position
	# Calculate duration as until_position - playback_position
	return entity.duration

func _on_seek() -> void:
	#video_widget = WhiteboardManager.search_widget_by_entity(video_entity) as VideoWidget
	if not video_widget: return
	_time_changed = true
	_connect_to_widget()
	video_widget.seek_video_deferred(get_entity().until_position - play_time)

func _on_skip() -> void:
	#video_widget = WhiteboardManager.search_widget_by_entity(video_entity) as VideoWidget
	if not video_widget: return
	video_widget.seek_video_deferred(get_entity().until_position)

func clear():
	reset()

func unclear():
	jump_to_end()

func get_entity() -> PlayVideoEntity:
	return entity as PlayVideoEntity

func _on_reference_changed() -> void:
	video_entity = get_entity().entity as VideoEntity

func _on_target_reached() -> void:
	finish_playing()
