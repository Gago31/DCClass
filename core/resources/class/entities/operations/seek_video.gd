class_name SeekVideoEntity
extends NodeReferenceEntity


var video_id: String = ""
@export var seek_position: float = 0.0
var _tree_item: TreeItem
var entity: VideoEntity


func _init() -> void:
	entity_id = "Seek Video"
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
	item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	item.set_range(1, seek_position)
	item.set_editable(1, entity != null)
	#if entity:
		#item.set_range_config(1, 0, entity.duration, 1)

func _on_value_updated_from_editor(item: TreeItem) -> void:
	var value := item.get_range(1)
	seek_position = value

func _is_node_valid(node: ClassNode) -> bool:
	if not node.is_leaf(): return false
	return (node as ClassLeaf).entity is VideoEntity
