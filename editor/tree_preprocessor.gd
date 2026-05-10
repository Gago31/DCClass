class_name TreePreprocessor
extends Node

var audio_files: Array[String] = []
var image_files: Array[String] = []
var video_files: Array[String] = []


func collect_resources(root: ClassRoot) -> UsedResources:
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
		audio_files.append((entity as AudioEntity).audio_path)
	elif entity is ImageEntity:
		image_files.append((entity as ImageEntity).image_path)
	elif entity is VideoEntity:
		video_files.append((entity as VideoEntity).video_path)

class UsedResources:
	var audio: Array[String]
	var images: Array[String]
	var video: Array[String]
	
	func _init(a: Array[String], i: Array[String], v: Array[String]) -> void:
		audio = a
		images = i
		video = v
