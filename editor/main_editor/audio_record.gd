class_name ClassAudioRecord
extends Node


var record_stream: AudioEffectRecord = AudioServer.get_bus_effect(AudioServer.get_bus_index("ClassRecord"), 0)
var record_data: AudioStreamWAV
var audio_index: int = 1

@onready var mic_stream := %AudioRecordStream
@onready var audio_stream_player := %AudioStreamPlayer


func start_recording() -> void:
	if record_stream.is_recording_active(): return
	record_data = null
	record_stream.set_recording_active(true)

func stop_recording() -> void:
	if not record_stream.is_recording_active(): return
	record_stream.set_recording_active(false)
	record_data = record_stream.get_recording()
	save_recording(record_data)

func play_recording() -> void:
	audio_stream_player.stream = record_data
	audio_stream_player.play()

func save_recording(_record_data: AudioStreamWAV) -> void:
	var temp_path := EditorManager.get_temp_path()
	var path_wav := "%s/%03d.wav" % [temp_path, audio_index]
	print("Saving audio from ", path_wav)
	audio_index += 1
	_record_data.save_to_wav(path_wav)
	var audio_entity := AudioEntity.new("", _record_data.get_length())
	var file_path := EditorManager.convert_audio(path_wav, audio_entity)
	audio_entity.audio_path = file_path
	EditorManager.add_entity(audio_entity)

func load_audio(file_name: String) -> AudioStreamOggVorbis:
	return EditorManager.load_audio(file_name)
