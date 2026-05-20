class_name SeekVideoEntity
extends NodeReferenceEntity

## An [Entity] that represents a seek operation for a video.
##
## This means that the video will jump to a specific time and the next time
## it is played it will begin from there.

## The time in seconds to which the video will seek to.
@export var seek_position: float = 0.0
var video_id: String = ""
var entity: VideoEntity


func _init() -> void:
	if node_reference:
		set_reference(node_reference)

func set_reference(node: ClassNode) -> void:
	entity = (node as ClassLeaf).entity as VideoEntity
	video_id = entity.video_path
	super.set_reference(node)
	if _tree_item:
		config_editor_tree_item(_tree_item)

func get_class_name() -> String:
	return "PlayVideoEntity"

func get_editor_name() -> String:
	return "Seek video: %s" % video_id

func get_widget() -> PackedScene:
	return preload("uid://dsgftp3ocdv4d")

func config_editor_tree_item(item: TreeItem) -> void:
	_tree_item = item
	item.set_text(0, get_editor_name())
	item.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
	_set_item_time_string()
	item.set_editable(1, entity != null)

func _on_value_updated_from_editor(item: TreeItem) -> void:
	var time_string := item.get_text(1)
	_set_time_from_string(time_string)

func _set_time_from_string(s: String) -> void:
	var valid := TimeString.is_valid(s)
	if not valid:
		_set_item_time_string()
		return
	seek_position = TimeString.to_seconds(s)
	print("Seek position: ", seek_position)
	_set_item_time_string()

func _set_item_time_string() -> void:
	_tree_item.set_text(1, TimeString.from_seconds(seek_position))

func _is_node_valid(node: ClassNode) -> bool:
	if not node.is_leaf(): return false
	return (node as ClassLeaf).entity is VideoEntity
