class_name PlayVideoEntity
extends NodeReferenceEntity


@export var until_position: float = 0.0
var video_id: String = ""
var _tree_item: TreeItem
var entity: VideoEntity

func _init() -> void:
	print("Init called")
	entity_id = "Play Video"
	if node_reference:
		set_reference(node_reference)

func set_reference(node: ClassNode) -> void:
	print("Set reference")
	prints("Node reference:", node_reference)
	entity = (node as ClassLeaf).entity as VideoEntity
	prints("entity:", entity)
	video_id = entity.video_path
	prints("video id:", video_id)
	super.set_reference(node)
	if _tree_item:
		config_editor_tree_item(_tree_item)

func get_class_name() -> String:
	return "PlayVideoEntity"

func get_editor_name() -> String:
	return "Play video: %s" % video_id

func get_widget() -> PackedScene:
	return preload("uid://c572m5e2lx7pw")

#func _get_time_string(t: float) -> String:
	#var total_seconds := snappedf(t, 0.01)
	#var seconds := fmod(total_seconds, 60)
	#var total_minutes := int(total_seconds - seconds) / 60
	#var minutes := total_minutes % 60
	#var hours := (total_minutes - minutes) / 60
	#var s := "%02d:%02d:%02.2f" % [hours, minutes, seconds]
	#return s

func _set_time_from_string(s: String) -> void:
	var valid := TimeString.is_valid(s)
	if not valid:
		_set_item_time_string()
		return
	until_position = TimeString.to_seconds(s)
	print("Until position: ", until_position)
	_set_item_time_string()

func _set_item_time_string() -> void:
	_tree_item.set_text(1, TimeString.from_seconds(until_position))

func config_editor_tree_item(item: TreeItem) -> void:
	_tree_item = item
	item.set_text(0, get_editor_name())
	#item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	item.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
	_set_item_time_string()
	#item.set_range(1, until_position)
	item.set_editable(1, entity != null)
	#if entity:
		#item.set_range_config(1, 0, entity.duration, 1)

func _on_value_updated_from_editor(item: TreeItem) -> void:
	#var value := item.get_range(1)
	var time_string := item.get_text(1)
	_set_time_from_string(time_string)
	#until_position = value

func _is_node_valid(node: ClassNode) -> bool:
	if not node.is_leaf(): return false
	return (node as ClassLeaf).entity is VideoEntity
