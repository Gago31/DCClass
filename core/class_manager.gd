class_name GlobalClassManager
extends Node


@export var metadata: ClassMetadata
@export var root: ClassRoot


func get_version() -> String:
	return metadata.app_version

func _pool_sync_nodes() -> void:
	pass
