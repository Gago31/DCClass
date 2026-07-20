class_name TreePreprocessor
extends Node

var audio_files: Array[String] = []
var image_files: Array[String] = []
var video_files: Array[String] = []


func collect_resources(root: ClassRoot) -> UsedResources:
	audio_files.clear()
	image_files.clear()
	video_files.clear()
	_collect_resources_from_node(root)
	var resources := UsedResources.new(audio_files, image_files, video_files)
	return resources

func _collect_resources_from_node(node: ClassNode) -> void:
	if node.is_leaf():
		_process_leaf_node(node as ClassLeaf)
	else:
		for child in (node as ClassGroup).children:
			_collect_resources_from_node(child)

func _process_leaf_node(node: ClassLeaf) -> void:
	var entity := node.entity
	if entity is AudioEntity:
		var path := (entity as AudioEntity).audio_path
		if path not in audio_files:
			audio_files.append(path)
	elif entity is ImageEntity:
		var path := (entity as ImageEntity).image_path
		if path not in image_files:
			image_files.append(path)
	elif entity is VideoEntity:
		var path := (entity as VideoEntity).video_path
		if path not in video_files:
			video_files.append(path)

class UsedResources:
	var audio: Array[String]
	var images: Array[String]
	var video: Array[String]
	
	func _init(a: Array[String], i: Array[String], v: Array[String]) -> void:
		audio = a
		images = i
		video = v
