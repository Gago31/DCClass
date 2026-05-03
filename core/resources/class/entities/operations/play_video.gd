class_name PlayVideoEntity
extends NodeReferenceEntity

# 2. docs: use docstring (##) to generate docs for this file
## An [Entity] that holds a reference to an image file.

# 3. signals: define signals here

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here
var video_id: String = ""
@export var until_position: float = 0.0
var _tree_item: TreeItem
var entity: VideoEntity
# 7. public variables: define all public variables here

# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here
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

#func serialize() -> Dictionary:
	#return {
		#"entity_id": entity_id,
		#"entity_type": get_class_name(),
		#"video_id": video_id,
		#"until_position": until_position
	#}

#func load_data(data: Dictionary) -> void:
	#video_id = data["video_id"]
	#until_position = data["until_position"]
	#duration = 0.0

func config_editor_tree_item(item: TreeItem) -> void:
	_tree_item = item
	item.set_text(0, get_editor_name())
	item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	item.set_range(1, until_position)
	item.set_editable(1, entity != null)
	#if entity:
		#item.set_range_config(1, 0, entity.duration, 1)

func _on_value_updated_from_editor(item: TreeItem) -> void:
	var value := item.get_range(1)
	until_position = value

func _is_node_valid(node: ClassNode) -> bool:
	if not node.is_leaf(): return false
	return (node as ClassLeaf).entity is VideoEntity

# 13. private methods: define all private methods here, use _ as preffix

# 14. subclasses: define all subclasses here
