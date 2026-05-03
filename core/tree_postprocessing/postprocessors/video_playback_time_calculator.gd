class_name VideoPlaybackPostprocessor
extends TreePostprocessor

var video_positions: Dictionary[VideoEntity, float] = {}

func reset() -> void:
	video_positions.clear()

func is_widget_valid(widget) -> bool:
	return widget is VideoWidget or \
		widget is PlayVideoWidget or \
		widget is SeekVideoWidget

func _process_widget(widget: Widget) -> void:
	if widget is VideoWidget:
		var entity := (widget as VideoWidget).get_entity()
		_register_video(entity)
		print("Registered video: ", entity.video_path)
	elif widget is PlayVideoWidget:
		_process_play_until(widget as PlayVideoWidget)
	elif widget is SeekVideoWidget:
		_process_seek(widget as SeekVideoWidget)

func _register_video(entity: VideoEntity) -> void:
	video_positions[entity] = 0.0

func _process_play_until(widget: PlayVideoWidget) -> void:
	var from := video_positions[widget.video_entity]
	var until := widget.get_entity().until_position
	print("Play video from %02fs to %02fs" % [from, until])
	if from > until: return
	var duration := until - from
	widget.get_entity().duration = duration
	video_positions[widget.video_entity] = until

func _process_seek(widget: SeekVideoWidget) -> void:
	var new_position := widget.get_entity().seek_position
	print("Seeking to %02fs" % new_position)
	video_positions[widget.video_entity] = new_position
