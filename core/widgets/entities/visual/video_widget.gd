class_name VideoWidget
extends VisualEntityWidget


signal reached_target_time

var _video_path: String
var volume: int
var video_paused := true
var _current_time: float
var video_duration: float
var video_file: FileAccess
var tween: Tween
var until_position: float = 0.0


@onready var converting_panel: PanelContainer = %ConvertingPanel
@onready var video_player: VideoStreamPlayerAv1 = %VideoPlayer
@onready var video_slider: HSlider = %VideoSlider
@onready var play_button: Button = %Play
@onready var mute: Button = %Mute
@onready var audio_slider: HSlider = %AudioSlider
@onready var fullscreen: Button = %Fullscreen


func setup() -> void:
	super.setup()
	_video_path = ClassResourceLoader.load_video(get_entity().video_path)
	video_player.file_name = _video_path
	if ClassResourceLoader.video_exists(get_entity().video_path):
		_on_video_converted(false)
	else:
		get_entity().conversion_finished.connect(_on_video_converted)
	hide()

func get_entity() -> VideoEntity:
	return entity as VideoEntity

func _on_started_playing() -> void:
	show()
	video_player.file_name = _video_path
	finish_playing()

func _on_reset():
	hide()

func _on_skip() -> void:
	show()

func _calculate_duration() -> float:
	return 0.0

func clear():
	reset()

func get_rect_bound() -> Rect2:
	if video_player:
		return Rect2(Vector2.ZERO, video_player.size)
	return Rect2(0, 0, 640, 480)

func _on_video_converted(_err: bool) -> void:
	converting_panel.hide()
	video_player.show()
	play_button.disabled = false
	print("Initializing playback")
	prints("file_path", video_player.file_name)
	video_player.init_playback()
	#video_player.play()
	#await get_tree().process_frame
	#video_player.pause()
	#video_player.play()
	#video_player.pause()
	#video_player.file_name = _video_path
	#video_player.play()

func play_video() -> void:
	print("play video")
	video_player.play()
	if not is_equal_approx(video_player.playback_position, _current_time):
		print("Rectifying position")
		seek_video(_current_time)
		#video_player.stop()
		#await get_tree().process_frame
		#video_player.play()
		#video_player.playback_position = _current_time
	var icon := play_button.icon as AtlasTexture
	icon.region.position.x = 200
	icon.region.position.y = 350

func pause_video() -> void:
	print("pause video")
	var icon := play_button.icon as AtlasTexture
	video_player.pause()
	icon.region.position.x = 350
	icon.region.position.y = 350

func play_video_until(until: float) -> void:
	#video_player.init_playback()
	if until <= _current_time: 
		reached_target_time.emit()
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	until_position = until
	play_video()

func seek_video(time: float) -> void:
	print("Seeking to ", time)
	#video_player.stop()
	#video_player.playback_position = 0.0
	#await get_tree().process_frame
	video_player.play()
	#await get_tree().process_frame
	#await get_tree().process_frame
	#await get_tree().process_frame
	_current_time = time
	video_player.playback_position = time
	#await get_tree().process_frame
	print("New time: ", video_player.playback_position)
	#video_player.pause()

func seek_video_deferred(time: float) -> void:
	_current_time = time

func _on_play_pressed() -> void:
	if video_player.playing:
		pause_video()
	else:
		play_video()

func _process(_delta: float) -> void:
	if video_player == null:
		return
	#print(video_player.playback_position)
	_current_time = video_player.playback_position
	if until_position != 0.0 and video_player.playing:
		if _current_time >= until_position:
			until_position = 0.0
			pause_video()
			process_mode = Node.PROCESS_MODE_DISABLED
			reached_target_time.emit()

func _compute_bounds() -> Rect2:
	var control := get_child(0) as Control
	return control.get_rect()
