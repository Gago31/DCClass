class_name GlobalEditorManager
extends Node


signal pen_mode_changed(value: PenMode)

## The way in which the whiteboard will handle pen movements.
enum PenMode {
	## The pen is inactive, the whiteboard will have the behavior of the player
	DISABLED,
	## Enables selection of [VisualEntityWidget]s by clicking them or drawing a
	## [SelectionBox] on the whiteboard.
	SELECT,
	## Allows the user to draw a line and adds it after the currently selected
	## node, or as its last child if it is a Group or Slide
	DRAW,
	## Moves a widget
	DRAG,
	## Resizes the widget
	RESIZE
}

@export var metadata: ClassMetadata
@export var root: ClassRoot

var current_group: ClassGroup
var undo_stack: Array[EditorAction]
var redo_stack: Array[EditorAction]
var _gui: EditorUI:
	set=set_editor_ui
var _project_dir: DirAccess
var _temp_dir: DirAccess
var changed := false
var pen_mode: PenMode = PenMode.DISABLED
var audio_index: int = 1
var video_index: int = 1
var image_index: int = 1
#var editor_tree: TreeManagerEditor

func set_editor_ui(gui: EditorUI) -> void:
	_gui = gui

func add_entity(entity: Entity) -> void:
	if not _gui: return
	_gui._add_entity(entity)

func add_image(path: String) -> void:
	var entity := ImageEntity.new()
	var tmp_path := entity.save_resource(path)
	entity.image_path = tmp_path
	#_add_entity(entity)

func add_video(path: String) -> void:
	var entity := VideoEntity.new()
	var tmp_path := entity.save_resource(path)
	
	# TODO: convert video, wait for thread completion and assign the video
	#var converted_path := start_video_conversion(entity, tmp_path)
	var converted_path := ""
	prints("Converted path", converted_path)
	entity.video_path = "resources/videos/%s" % converted_path
	#_add_entity(entity)


func add_line() -> void:
	pass

func undo() -> void:
	pass

func redo() -> void:
	pass
	
func record_audio() -> void:
	AudioRecorder.start_recording()

func stop_recording() -> void:
	AudioRecorder.stop_recording()

func save() -> void:
	var path_metadata := _project_dir.get_current_dir() + "/metadata.res"
	var path_tree := _project_dir.get_current_dir() + "/class_tree.res"
	var path_state := _project_dir.get_current_dir() + "/editor_state.res"
	var state := EditorState.new()
	state.audio_index = audio_index
	state.image_index = image_index
	state.video_index = video_index
	ResourceSaver.save(metadata, path_metadata, ResourceSaver.FLAG_COMPRESS)
	ResourceSaver.save(root, path_tree, ResourceSaver.FLAG_COMPRESS)
	ResourceSaver.save(state, path_state, ResourceSaver.FLAG_COMPRESS)

func _sync_whiteboard() -> void:
	WhiteboardManager.root = root
	WhiteboardManager.metadata = metadata

func create_project(dir: String) -> void:
	_project_dir = DirAccess.open(dir)
	_project_dir.make_dir_recursive("assets/audio")
	_project_dir.make_dir_recursive("assets/images")
	_project_dir.make_dir_recursive("assets/video")
	_clear_temp_dir()
	_project_dir.make_dir("temp")
	_temp_dir = DirAccess.open(_project_dir.get_current_dir() + "/temp")
	#_temp_dir = 
	metadata = ClassMetadata.new()
	root = ClassRoot.new()
	save()
	_sync_whiteboard()

func load_project(dir: String) -> Error:
	_project_dir = DirAccess.open(dir)
	var metadata_exists := _project_dir.file_exists("metadata.res")
	var tree_exists := _project_dir.file_exists("class_tree.res")
	if not metadata_exists or not tree_exists:
		return FAILED
	
	var path_metadata := _project_dir.get_current_dir() + "/metadata.res"
	var path_tree := _project_dir.get_current_dir() + "/class_tree.res"
	var path_state := _project_dir.get_current_dir() + "/editor_state.res"
	#metadata = ResourceLoader.load(path_metadata, "ClassMetadata") as ClassMetadata
	metadata = load(path_metadata) as ClassMetadata
	if not metadata:
		return FAILED
	#TODO: check metadata version before loading class
	#root = ResourceLoader.load(path_tree, "ClassRoot") as ClassRoot
	root = load(path_tree) as ClassRoot
	if not root:
		return FAILED
	
	var state := load(path_state) as EditorState
	if state:
		audio_index = state.audio_index
		image_index = state.image_index
		video_index = state.video_index

	_clear_temp_dir()
	_project_dir.make_dir("temp")
	_temp_dir = DirAccess.open(_project_dir.get_current_dir() + "/temp")
	#_temp_dir = DirAccess.create_temp("temp")
	_sync_whiteboard()
	return OK

func _clear_temp_dir() -> void:
	#var dir = DirAccess.open("<path to folder>")
	if not _temp_dir:
		if not _project_dir.dir_exists("temp"): return
		_temp_dir = DirAccess.open(_project_dir.get_current_dir() + "/temp")
	for file in _temp_dir.get_files():
		_temp_dir.remove(file)
	_project_dir.remove("temp")

func export_project(path: String) -> void:
	pass

# Decompress a zip file to a temporary directory.
func decompress_zip(__zip_path: String, __dir_tmp: String) -> bool:
	var reader: ZIPReader = ZIPReader.new()
	var err = reader.open(__zip_path)
	if err != OK:
		return false

	if not __dir_tmp.ends_with("/"):
		__dir_tmp += "/"

	if DirAccess.dir_exists_absolute(__dir_tmp):
		_remove_dir_recursively(__dir_tmp)

	DirAccess.make_dir_recursive_absolute(__dir_tmp)

	for internal_path in reader.get_files():
		var absolute_path := __dir_tmp + internal_path
		if internal_path.ends_with("/"):
			DirAccess.make_dir_recursive_absolute(absolute_path)
			continue

		DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())

		var file := FileAccess.open(absolute_path, FileAccess.WRITE)
		if not file:
			reader.close()
			return false
		file.store_buffer(reader.read_file(internal_path))
		file.close()

	reader.close()
	return true

# Remove a directory and all its contents recursively.
# This function is used to clean up temporary directories created during the parsing process.
func _remove_dir_recursively(path_del: String) -> void:
	for sub_dir in DirAccess.get_directories_at(path_del):
		_remove_dir_recursively(path_del.path_join(sub_dir) + "/")

	for file_name in DirAccess.get_files_at(path_del):
		DirAccess.remove_absolute(path_del.path_join(file_name))

	DirAccess.remove_absolute(path_del)

func set_pen_mode(value: PenMode) -> void:
	pen_mode = value
	pen_mode_changed.emit(pen_mode)

func save_asset(data, folder: String, file_name: String) -> void:
	pass

func save_asset_temp(data, file_name: String) -> void:
	pass

func save_resource(path: String) -> String:
	var filename = path.split("/")[-1]
	var extension = filename.split(".")[-1]
	var raw_name = filename.replace("." + extension, "")
	var salted_name = raw_name + str(Time.get_unix_time_from_system()) + "." + extension
	
	var path_tmp: String = "user://tmp/class_editor/"
	var path_images: String = "resources/images/"

	var full_path = path_tmp + path_images
	if !DirAccess.dir_exists_absolute(full_path):
		DirAccess.make_dir_recursive_absolute(full_path)
	DirAccess.copy_absolute(path, full_path + salted_name)
	return path_images + salted_name

## Starts a thread converting the audio file in `input_path`
## to an `*.ogg` file. Notifies `entity` when the conversion finishes.[/b]
## Returns the name of the output file.
func convert_audio(input_path: String, entity: AudioEntity) -> String:
	var assets_path := get_assets_path()
	var file_name := "%03d.ogg" % audio_index
	var path_ogg := "%s/audio/%s" % [assets_path, file_name]
	var args := ["-y", "-i", input_path, "-c:a", "libvorbis", path_ogg]
	var thread_notifier := ThreadNotifier.new()
	add_child(thread_notifier)
	thread_notifier.thread_finished.connect(entity._on_audio_converted)
	thread_notifier.run_thread(OS.execute.bind("ffmpeg", args, []))
	audio_index += 1
	return file_name

## Starts a thread converting the video file in `input_path`
## to a `*.webm` file. Notifies `entity` when the conversion finishes.[/b]
## Returns the name of the output file.
func convert_video(entity: VideoEntity, input_path: String) -> String:
	print("Loading file ", input_path)
	var output_name := '%02d.webm' % video_index
	var output_path := "%s/video/%s" % [get_assets_path(), output_name]
	prints("Input path:", )
	prints("Output path:", output_path)
	var command_args := [
		"-i", input_path, 
		"-y", 
		"-vcodec", "libsvtav1",
		"-acodec", "libopus",
		"-crf", 35,
		"-vf", "scale=-2:480", #"scale=-1:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,setsar=1"
		"-preset", 6,
		"-g", 300,
		"-svtav1-params", "tune=0",
		output_path
	]
	var thread_notifier := ThreadNotifier.new()
	add_child(thread_notifier)
	thread_notifier.thread_finished.connect(entity._on_video_converted.bind(output_path))
	#thread_notifier.thread_finished.connect()
	thread_notifier.run_thread(OS.execute.bind("ffmpeg", command_args, thread_notifier._output))
	video_index += 1
	return output_name

func get_temp_path() -> String:
	return _temp_dir.get_current_dir()

func get_assets_path() -> String:
	return _project_dir.get_current_dir() + "/assets"

func load_audio(file_name: String) -> AudioStreamOggVorbis:
	var file_path := get_assets_path()+ "/audio/" + file_name
	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file: return
	var data := file.get_buffer(file.get_length())
	var sound = AudioStreamOggVorbis.load_from_buffer(data)
	return sound

func video_exists(video_name: String) -> bool:
	var video_path := get_assets_path() + "/video/" + video_name
	return FileAccess.file_exists(video_path)
