class_name ExternalResourceLoader
extends Node

## Autoload that handles the loading of resources for widgets.
##
## Its autoload name is [ClassResourceLoader].

## Wether the app running is the editor or the player.
@export var is_editor: bool

var _zip: ZIPReader
var _temp_dir: DirAccess
var _metadata: ClassMetadata
var _root: ClassRoot


## Loads the data of a *.dcc file, setting up the [ClassMetadata], [ClassRoot]
## and extracting any resources that need to be decompressed before playing
## the class.
func open_dcc_file(path: String) -> Error:
	print("----------------------")
	print("Opening DCC file")
	_zip = ZIPReader.new()
	_temp_dir = DirAccess.create_temp("temp")
	_temp_dir.make_dir_recursive("assets/video")
	var err := _zip.open(path)
	if err: return Error.ERR_CANT_OPEN
	
	var metadata_bytes := _zip.read_file("metadata.res")
	_save_temp_file("metadata.res", metadata_bytes)
	_metadata = load(_temp_path("metadata.res")) as ClassMetadata
	if not _metadata: return Error.ERR_FILE_CANT_READ
	# TODO: Check DCClass version
	
	var tree_bytes := _zip.read_file("class_tree.res")
	_save_temp_file("class_tree.res", tree_bytes)
	_root = load(_temp_path("class_tree.res")) as ClassRoot
	if not _root: return Error.ERR_FILE_CANT_READ
	
	# Videos have to be decompressed to play them
	for file_name in _zip.get_files():
		print("Zip file: ", file_name)
		if file_name.ends_with("/"): continue
		if file_name.contains("video/"):
			print("Extracting ", file_name)
			var bytes := _zip.read_file(file_name)
			_save_temp_file(file_name, bytes)
	print("----------------------")
	return OK

## Returns the loaded [ClassMetadata].
func get_class_metadata() -> ClassMetadata:
	return _metadata

## Returns the loaded [ClassRoot].
func get_class_tree() -> ClassRoot:
	return _root

## Wether an image with the given [param file_name] is present within the
## class files.
func image_exists(file_name: String) -> bool:
	if is_editor:
		return EditorManager.image_exists(file_name)
	return _file_exists_in_zip("assets/images/" + file_name)

## Loads an image with the given [param file_name] from the class resources,
## and returns it as a [Texture2D].
func load_image(file_name: String) -> Texture2D:
	if is_editor:
		return EditorManager.load_image(file_name)
	if not image_exists(file_name): return null
	var extension := file_name.split(".")[-1]
	var data := _zip.read_file("assets/images/" + file_name)
	var image := Image.new()
	match extension:
		"png": image.load_png_from_buffer(data)
		"jpg": image.load_jpg_from_buffer(data)
		"svg": image.load_svg_from_buffer(data)
		"bmp": image.load_bmp_from_buffer(data)
		"webp": image.load_webp_from_buffer(data)
		_: push_error("Unsupported image format: " + extension)
	return ImageTexture.create_from_image(image)

## Wether a video with the given [param file_name] is present within the
## class files.
func video_exists(file_name: String) -> bool:
	if is_editor:
		return EditorManager.video_exists(file_name)
	return _file_exists_in_zip("assets/video/" + file_name)

## Returns the absolute path in the file system of a video with the given
## [param file_name] in the class resources.[br][br]
##
## It doesn't really load the video, because that is done when opening the
## class file in [method open_dcc_file] and the library used to play videos
## just takes the absolute path of the video.
func load_video(file_name: String) -> String:
	if is_editor:
		return EditorManager.load_video(file_name)
	if video_exists(file_name):
		return _temp_path("assets/video/%s" % file_name)
	return ""

## Wether an audio file with the given [param file_name] is present within the
## class files.
func audio_exists(file_name: String) -> bool:
	if is_editor:
		return EditorManager.audio_exists(file_name)
	return _file_exists_in_zip("assets/audio/" + file_name)

## Loads the audio file with the given [param file_name] from the class 
## resources, and returns it as an [AudioStreamOggVorbis].
func load_audio(file_name: String) -> AudioStreamOggVorbis:
	if is_editor:
		return EditorManager.load_audio(file_name)
	
	if not _zip: return null
	var buffer := _zip.read_file("assets/audio/" + file_name)
	var stream := AudioStreamOggVorbis.load_from_buffer(buffer)
	return stream

func _temp_path(rel_path: String) -> String:
	return _temp_dir.get_current_dir() + "/" + rel_path

func _save_temp_file(rel_path: String, buffer: PackedByteArray) -> Error:
	if not _temp_dir: return Error.ERR_DOES_NOT_EXIST
	var path := _temp_path(rel_path)
	var file := FileAccess.open(path, FileAccess.WRITE)
	var err := file.store_buffer(buffer)
	if err: return Error.ERR_CANT_CREATE
	return OK

func _file_exists_in_zip(path: String) -> bool:
	return _zip.file_exists(path)
