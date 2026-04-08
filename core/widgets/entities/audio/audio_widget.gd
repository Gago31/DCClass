class_name AudioWidget
extends Widget

@export var entity: AudioEntity
var crossfade_tween: Tween
var crossfade_duration: float = 0.06
var audio: AudioStreamPlayer


func init(_properties: Dictionary) -> void:
	var data
	
	crossfade_tween = null
	
	# Case: Keep data in the .dcc file
	# This is intended to be used only for reproducing the class.
	if zip_file != null:
		if !zip_file.file_exists(entity.audio_path):
			push_error("Audio file not found: " + entity.audio_path)
			return
		data = zip_file.read_file(entity.audio_path)
		
	# Case: Decompress the .dcc file
	# This is intended to be used only for editing the class.
	else:
		var relative_path: String = entity.audio_path
		var audio_disk_path: String = dir_class.path_join(relative_path)
		if not FileAccess.file_exists(audio_disk_path):
			push_error("Audio file not found: " + audio_disk_path)
			return
		var f := FileAccess.open(audio_disk_path, FileAccess.READ)
		if f == null:
			push_error("No se pudo abrir: " + audio_disk_path)
			return
		data = f.get_buffer(f.get_length())
		f.close()
	
	var packet_sequence := AudioStreamOggVorbis.load_from_buffer(data)
	audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.bus = &"AudioWidget"
	audio.stream = packet_sequence

# Serialize to a dictionary format(.json) for saving.
func serialize() -> Dictionary:
	return entity.serialize()

func crossfade(from: AudioWidget, _seek_time: float = -1):
	var fade_out_db = -80.0
	var fade_in_db = 0.0
	
	if crossfade_tween:
		crossfade_tween.kill()
	
	crossfade_tween = create_tween()
	crossfade_tween.set_parallel(true)
	
	if audio and is_instance_valid(audio):
		audio.volume_db = -80.0
		
		if _seek_time != -1:
			audio.play(_seek_time)
		else:
			audio.play()
	
		if from and is_instance_valid(from.audio):
			crossfade_tween.tween_property(from.audio, "volume_db", fade_out_db, crossfade_duration)
			
			# stop audio after fade out
			crossfade_tween.tween_callback(from.stop_after_fade.bind(from)).set_delay(crossfade_duration)
		
		crossfade_tween.tween_property(audio, "volume_db", fade_in_db, crossfade_duration)
	
func crossfade_in(_seek_time: float = -1):
	var fade_in_db = 0.0
	
	if crossfade_tween:
		crossfade_tween.kill()
		
	crossfade_tween = create_tween()
	
	if audio and is_instance_valid(audio):
		audio.volume_db = -80.0
		
		if _seek_time != -1:
			audio.play(_seek_time)
		else:
			audio.play()
			
		crossfade_tween.tween_property(audio, "volume_db", fade_in_db, crossfade_duration)
	
# stops the audio after a fade
func stop_after_fade(act_audio: AudioWidget):
	if act_audio.audio.playing:
		stop()

func _ready():
	add_to_group(&"speed_scale_handler")

# Play the audio file.
func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	# Check if another audio is playing to wait for it to finish
	var audio_current_playing = get_tree().get_nodes_in_group("audio_playing")
	
	if audio_current_playing.size() > 0:
		# audio pending
		var prev_audio = audio_current_playing[0]
		
		if prev_audio != self:
			# fade if its a different audio
			var time_remaining = prev_audio.audio.stream.get_length() - prev_audio.audio.get_playback_position()
			
			if time_remaining <= crossfade_duration:
				crossfade(prev_audio)
				
			else:
				# creating a timer for the fade out
				var delay = time_remaining - crossfade_duration
				await get_tree().create_timer(delay).timeout
				
				if prev_audio.audio.playing:
					crossfade(prev_audio)
		else:
			# the audio is the same, no crossfade
			crossfade_in()
			
	else:
		# there's no other audio
		crossfade_in()
	
	add_to_group(&"audio_playing")
	add_to_group(&"widget_playing")
		
	# Wait until this audio is terminated or finished 
	var sigs: Array[Signal] = [audio.finished, _bus_core.stop_widget]
	var state = SignalsCore.await_any_once(sigs)
	
	_bus_core.current_node_changed.emit(class_node)
	
	add_to_group(&"audio_playing")
	add_to_group(&"widget_playing")
	emit_signal("widget_finished")
	
	if !state._done:
		await state.completed
		reset()

# Play the audio file from a specific time.
func seek_and_play(_seek_time: float) -> void:
	# Border case: if the seek time is zero or the audio is already at the end, we finish immediately to avoid unnecessary courutines problems.
	if is_zero_approx(_seek_time - compute_duration()):
		emit_signal("widget_finished")
		return
		
	# Check if another audio is playing to wait for it to finish
	var audio_current_playing = get_tree().get_nodes_in_group("audio_playing")
	
	if audio_current_playing.size() > 0:
		# audio pending
		var prev_audio = audio_current_playing[0]
		
		if prev_audio != self:
			# fade if its a different audio
			crossfade(prev_audio, _seek_time)
		else:
		# the audio is the same
			crossfade_in(_seek_time)
	else:
		# there's no other audio
		crossfade_in(_seek_time)
	
	add_to_group(&"audio_playing")
	add_to_group(&"widget_playing")
	emit_signal("widget_finished")
	
	_bus_core.current_node_changed.emit(class_node)
	
	var sigs: Array[Signal] = [audio.finished, _bus_core.stop_widget]
	var state = SignalsCore.await_any_once(sigs)
	
	if !state._done:
		await state.completed
		reset()

# Stop the audio.
func stop():
	reset()
	emit_signal("widget_finished")

# Reset the audio player. This mean set to the initial state and remove from playing groups.
func reset():
	audio.stop()
	remove_from_group(&"audio_playing")
	remove_from_group(&"widget_playing")

# Skip to the end of the audio.
func skip_to_end():
	reset()
	emit_signal("widget_finished")

func _clear():
	pass

func set_speed_scale(_speed: float) -> void:
	audio.pitch_scale = _speed

## Returns the duration of the audio in seconds.
func compute_duration() -> float:
	return audio.stream.get_length()
