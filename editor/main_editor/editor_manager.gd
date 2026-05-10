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
var _gui: EditorUI:
	set=set_editor_ui
var _project_dir: DirAccess
var _temp_dir: DirAccess
var changed := false
var pen_mode: PenMode = PenMode.DISABLED
var audio_index: int = 1
var video_index: int = 1
var image_index: int = 1
var zip: ZIPPacker
@onready var tree_preprocessor: TreePreprocessor = $TreePreprocessor


func set_editor_ui(gui: EditorUI) -> void:
	_gui = gui

func add_entity(entity: Entity) -> void:
	if not _gui: return
	_gui._add_entity(entity)

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
	save()
	zip = ZIPPacker.new()
	zip.open(path)
	var used_resources := tree_preprocessor.collect_resources(root)
	
	for audio in used_resources.audio:
		_store_asset("audio", audio)
	for image in used_resources.images:
		_store_asset("images", image)
	for video in used_resources.video:
		_store_asset("video", video)
	_store_res("metadata.res")
	_store_res("class_tree.res")
	zip.close()

func _store_asset(folder: String, file_name: String) -> void:
	if not zip: return
	var asset_path := get_assets_path().path_join(folder).path_join(file_name)
	var zip_path := "assets/".path_join(folder).path_join(file_name)
	var data := FileAccess.get_file_as_bytes(asset_path)
	zip.start_file(zip_path)
	zip.write_file(data)
	zip.close_file()

func _store_res(file_name: String) -> void:
	if not zip: return
	var path := _project_dir.get_current_dir().path_join(file_name)
	var data := FileAccess.get_file_as_bytes(path)
	zip.start_file(file_name)
	zip.write_file(data)
	zip.close_file()

#func zip_folder(source_dir: String, zip_path: String) -> Error:
	#var zipper := ZIPPacker.new()
	#var err := zipper.open(zip_path)
	#if err != OK:
		#push_error("Can't open the file to write:: %s (Error %d)" % [zip_path, err])
		#return err
#
	#_add_folder_to_zip(zipper, source_dir, "")
	#zipper.close()
	#return OK
#
#func _add_folder_to_zip(zipper: ZIPPacker, current_dir: String, relative_path: String) -> void:
	#for file_name in DirAccess.get_files_at(current_dir):
		#var file_path := current_dir.path_join(file_name)
		#var path_in_zip := relative_path + file_name
		#
		#var f := FileAccess.open(file_path, FileAccess.READ)
		#if f == null:
			#push_error("Can't open the file to read: %s" % file_path)
			#continue
		#var data := f.get_buffer(f.get_length())
		#f.close()
#
		#var err_start := zipper.start_file(path_in_zip)
		#if err_start != OK:
			#push_error("Error Zip: %s (Error %d)" % [path_in_zip, err_start])
			#continue
#
		#zipper.write_file(data)
		#zipper.close_file()
#
	#for subdir in DirAccess.get_directories_at(current_dir):
		#var subdir_path := current_dir.path_join(subdir) + "/"
		#var new_relative := relative_path + subdir + "/"
#
		#_add_folder_to_zip(zipper, subdir_path, new_relative)

# Decompress a zip file to a temporary directory.
#func decompress_zip(__zip_path: String, __dir_tmp: String) -> bool:
	#var reader: ZIPReader = ZIPReader.new()
	#var err = reader.open(__zip_path)
	#if err != OK:
		#return false
#
	#if not __dir_tmp.ends_with("/"):
		#__dir_tmp += "/"
#
	#if DirAccess.dir_exists_absolute(__dir_tmp):
		#_remove_dir_recursively(__dir_tmp)
#
	#DirAccess.make_dir_recursive_absolute(__dir_tmp)
#
	#for internal_path in reader.get_files():
		#var absolute_path := __dir_tmp + internal_path
		#if internal_path.ends_with("/"):
			#DirAccess.make_dir_recursive_absolute(absolute_path)
			#continue
#
		#DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
#
		#var file := FileAccess.open(absolute_path, FileAccess.WRITE)
		#if not file:
			#reader.close()
			#return false
		#file.store_buffer(reader.read_file(internal_path))
		#file.close()
#
	#reader.close()
	#return true

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

#func save_asset(data, folder: String, file_name: String) -> void:
	#pass
#
#func save_asset_temp(data, file_name: String) -> void:
	#pass

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

func convert_image(entity: ImageEntity, input_path: String) -> String:
	print("Loading file ", input_path)
	var extension := input_path.split(".")[-1]
	var output_name := "%02d.%s" % [video_index, extension]
	var output_path := "%s/images/%s" % [get_assets_path(), output_name]
	prints("Input path:", )
	prints("Output path:", output_path)
	var command_args := [
		"-i", input_path, 
		"-y",
		output_path
	]
	var thread_notifier := ThreadNotifier.new()
	add_child(thread_notifier)
	thread_notifier.thread_finished.connect(entity._on_image_converted.bind(output_path))
	#thread_notifier.thread_finished.connect()
	thread_notifier.run_thread(OS.execute.bind("ffmpeg", command_args, thread_notifier._output))
	image_index += 1
	return output_name

func get_temp_path() -> String:
	return _temp_dir.get_current_dir()

func get_assets_path() -> String:
	return _project_dir.get_current_dir() + "/assets"

func load_audio(file_name: String) -> AudioStreamOggVorbis:
	var file_path := get_assets_path()+ "/audio/" + file_name
	#var file := FileAccess.open(file_path, FileAccess.READ)
	#if not file: return null
	#var data := file.get_buffer(file.get_length())
	var data := FileAccess.get_file_as_bytes(file_path)
	var sound := AudioStreamOggVorbis.load_from_buffer(data)
	return sound

func load_image(file_name: String) -> Texture2D:
	var file_path := get_assets_path()+ "/images/" + file_name
	#var file := FileAccess.open(file_path, FileAccess.READ)
	#if not file: return null
	#var data := file.get_buffer(file.get_length())
	#var data := FileAccess.get_file_as_bytes(file_path)
	var image := Image.load_from_file(file_path)
	var texture := ImageTexture.create_from_image(image)
	return texture

func load_video(file_name: String) -> String:
	var file_path := get_assets_path()+ "/video/" + file_name
	return file_path

func video_exists(video_name: String) -> bool:
	var video_path := get_assets_path() + "/video/" + video_name
	return FileAccess.file_exists(video_path)

func image_exists(image_name: String) -> bool:
	var image_path := get_assets_path() + "/images/" + image_name
	return FileAccess.file_exists(image_path)

func audio_exists(file_name: String) -> bool:
	var file_path := get_assets_path() + "/audio/" + file_name
	return FileAccess.file_exists(file_path)
