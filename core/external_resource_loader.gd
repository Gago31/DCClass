class_name ExternalResourceLoader
extends Node


@export var is_editor: bool

var zip: ZIPReader
var temp_dir: DirAccess
var _metadata: ClassMetadata
var _root: ClassRoot
var file_loaded


func open_dcc_file(path: String) -> Error:
	print("----------------------")
	print("Opening DCC file")
	zip = ZIPReader.new()
	temp_dir = DirAccess.create_temp("temp")
	temp_dir.make_dir_recursive("assets/video")
	var err := zip.open(path)
	if err: return Error.ERR_CANT_OPEN
	
	var metadata_bytes := zip.read_file("metadata.res")
	_save_temp_file("metadata.res", metadata_bytes)
	_metadata = load(_temp_path("metadata.res")) as ClassMetadata
	if not _metadata: return Error.ERR_FILE_CANT_READ
	# TODO: Check DCClass version
	
	var tree_bytes := zip.read_file("class_tree.res")
	_save_temp_file("class_tree.res", tree_bytes)
	_root = load(_temp_path("class_tree.res")) as ClassRoot
	if not _root: return Error.ERR_FILE_CANT_READ
	
	# Videos have to be decompressed to play them
	for file_name in zip.get_files():
		print("Zip file: ", file_name)
		if file_name.ends_with("/"): continue
		if file_name.contains("video/"):
			print("Extracting ", file_name)
			var bytes := zip.read_file(file_name)
			_save_temp_file(file_name, bytes)
	print("----------------------")
	return OK

func get_class_metadata() -> ClassMetadata:
	return _metadata

func get_class_tree() -> ClassRoot:
	return _root

func _temp_path(rel_path: String) -> String:
	return temp_dir.get_current_dir() + "/" + rel_path

func _save_temp_file(rel_path: String, buffer: PackedByteArray) -> Error:
	if not temp_dir: return Error.ERR_DOES_NOT_EXIST
	var path := _temp_path(rel_path)
	var file := FileAccess.open(path, FileAccess.WRITE)
	var err := file.store_buffer(buffer)
	if err: return Error.ERR_CANT_CREATE
	return OK

func _file_exists_in_zip(path: String) -> bool:
	return zip.file_exists(path)

func image_exists(file_name: String) -> bool:
	if is_editor:
		return EditorManager.image_exists(file_name)
	return _file_exists_in_zip("assets/images/" + file_name)

func load_image(file_name: String) -> Texture2D:
	if is_editor:
		return EditorManager.load_image(file_name)
	if not image_exists(file_name): return null
	var extension := file_name.split(".")[-1]
	var data := zip.read_file("assets/images/" + file_name)
	var image := Image.new()
	match extension:
		"png": image.load_png_from_buffer(data)
		"jpg": image.load_jpg_from_buffer(data)
		"svg": image.load_svg_from_buffer(data)
		"bmp": image.load_bmp_from_buffer(data)
		"webp": image.load_webp_from_buffer(data)
		_: push_error("Unsupported image format: " + extension)
	return ImageTexture.create_from_image(image)

func video_exists(file_name: String) -> bool:
	if is_editor:
		return EditorManager.video_exists(file_name)
	return _file_exists_in_zip("assets/video/" + file_name)

func load_video(file_name: String) -> String:
	if is_editor:
		return EditorManager.load_video(file_name)
	if video_exists(file_name):
		return _temp_path("assets/video/%s" % file_name)
	return ""

func audio_exists(file_name: String) -> bool:
	if is_editor:
		return EditorManager.audio_exists(file_name)
	return _file_exists_in_zip("assets/audio/" + file_name)

func load_audio(file_name: String) -> AudioStreamOggVorbis:
	if is_editor:
		return EditorManager.load_audio(file_name)
	
	if not zip: return null
	var buffer := zip.read_file("assets/audio/" + file_name)
	var stream := AudioStreamOggVorbis.load_from_buffer(buffer)
	return stream
