class_name VideoWidget
extends Widget

const scene = preload("res://core/widgets/entities/visual/video_widget.tscn")

@export var entity: VideoEntity
var video_player: Control
var _video_stream_player: VideoStreamPlayerAv1
var _playback_enabled := false
var _video_path: String
var volume: int
var paused := true
var current_time: float
var video_duration: float
var video_file: FileAccess
var tween: Tween
var until_position: float = 0.0

func init(properties: Dictionary) -> void:
	var data
	print(entity.video_path)
	entity.conversion_finished.connect(_on_video_converted)
	if zip_file != null:
		if !zip_file.file_exists(entity.video_path):
			push_error("Video file not found: " + entity.video_path)
			return
		data = zip_file.read_file(entity.video_path)
		video_file = FileAccess.create_temp(FileAccess.WRITE, "video", "webm", false)
		video_file.store_buffer(data)
		_video_path = video_file.get_path()
	else:
		var relative_path: String = entity.video_path
		var video_disk_path: String = dir_class.path_join(relative_path)
		#if not FileAccess.file_exists(video_disk_path):
			#push_error("Video file not found: " + video_disk_path)
			#return
		#var f := FileAccess.open(video_disk_path, FileAccess.READ)
		#if f == null:
			#push_error("No se pudo abrir: " + video_disk_path)
			#return
		#data = f.get_buffer(f.get_length())
		#f.close()
		_video_path = video_disk_path
		prints("Video path:", _video_path)

	#var texture := _create_texture(data)
	video_player = scene.instantiate()
	add_child(video_player)
	(video_player.get_node("%Play") as Button).pressed.connect(_on_play_pressed)
	_video_stream_player = video_player.get_node_or_null("%VideoPlayer")
	if not _video_stream_player:
		print("Null player!!!")
	_video_stream_player.file_name = ProjectSettings.globalize_path(_video_path)
	#await get_tree().process_frame
	
	#image = scene.instantiate()
	#image.stretch_mode = TextureRect.STRETCH_SCALE 
	if properties.has("position"):
		position = properties["position"]
	if properties.has("size"):
		video_player.size = properties["size"]
	#video_player.file_name
	#image.texture = texture
	
	if class_node is ClassLeaf:
		(class_node as ClassLeaf).property_updated.connect(_on_property_updated)

func serialize() -> Dictionary:
	return entity.serialize()

func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	#image.modulate = Color(1,1,1,0)
	video_player.show()
	_video_stream_player = video_player.get_node("%VideoPlayer")
	_video_stream_player.file_name = _video_path
	_video_stream_player.play()
	#_video_stream_player.stop()
	#tween = create_tween()
	#tween.tween_property(image, "modulate", Color(1, 1, 1, 1), entity.duration)
	_bus_core.current_node_changed.emit(class_node)

	add_to_group(&"playing_widget")
	remove_from_group(&"widget_playing")
	add_to_group(&"widget_finished")
	emit_signal("widget_finished")

func reset():
	if tween:
		tween.kill()
	if video_player:
		video_player.hide()
	remove_from_group(&"widget_playing")
	remove_from_group(&"widget_finished")
	emit_signal("widget_finished")

func stop() -> void:
	skip_to_end()

func skip_to_end() -> void:
	if tween:
		tween.kill()
	if video_player:
		video_player.show()
	# image.modulate = Color(1, 1, 1, 1)
	add_to_group(&"widget_finished")
	emit_signal("widget_finished")

func clear():
	reset()
	add_to_group(&"widget_cleared")

func unclear():
	skip_to_end()
	remove_from_group(&"widget_cleared")

func get_rect_bound() -> Rect2:
	if video_player:
		return Rect2(Vector2.ZERO, video_player.size)
	return Rect2(0, 0, 640, 480)

#func _create_texture(data: PackedByteArray) -> Texture2D:
	#var _image := Image.new()
	#match entity.image_path.split(".")[-1]:
		#"png": _image.load_png_from_buffer(data)
		#"jpg": _image.load_jpg_from_buffer(data)
		#"svg": _image.load_svg_from_buffer(data)
		#"bmp": _image.load_bmp_from_buffer(data)
		#_: push_error("Unsupported image format: " + entity.image_path.split(".")[-1])
	#return ImageTexture.create_from_image(_image)

func _on_property_updated(property: EntityProperty) -> void:
	if property is PositionEntityProperty:
		position = property.position
	elif property is SizeEntityProperty:
		video_player.size = property.size

func _on_video_converted(_err: bool) -> void:
	#if err:
		#print("Error converting")
		#return
	video_player.get_node("%ConvertingPanel").hide()
	video_player.get_node("%VideoPlayer").show()
	video_player.get_node("%Play").disabled = false

func play_video() -> void:
	var play_button: Button = video_player.get_node("%Play")
	var icon := play_button.icon as AtlasTexture
	_video_stream_player.play()
	icon.region.position.x = 200
	icon.region.position.y = 350

func pause_video() -> void:
	var play_button: Button = video_player.get_node("%Play")
	var icon := play_button.icon as AtlasTexture
	_video_stream_player.pause()
	icon.region.position.x = 350
	icon.region.position.y = 350

func play_video_until(until: float) -> void:
	until_position = until
	play_video()

func _on_play_pressed() -> void:
	if _video_stream_player.playing:
		pause_video()
	else:
		play_video()

func _process(_delta: float) -> void:
	if _video_stream_player == null:
		return
	if until_position != 0.0 and _video_stream_player.playing:
		if _video_stream_player.playback_position >= until_position:
			until_position = 0.0
			pause_video()
