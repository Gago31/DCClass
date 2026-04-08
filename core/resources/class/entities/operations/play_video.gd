@tool
class_name PlayVideoEntity
extends Entity

# 2. docs: use docstring (##) to generate docs for this file
## An [Entity] that holds a reference to an image file.

# 3. signals: define signals here

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here
@export var video_id: String
@export var until_position: float = 0.0
# 7. public variables: define all public variables here

# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here
func _init() -> void:
	entity_id = "Play Video"

func get_class_name() -> String:
	return "PlayVideoEntity"

func get_editor_name() -> String:
	return "Play video: %s" % video_id

func serialize() -> Dictionary:
	return {
		"entity_id": entity_id,
		"entity_type": get_class_name(),
		"video_id": video_id,
		"until_position": until_position
	}

func load_data(data: Dictionary) -> void:
	video_id = data["video_id"]
	until_position = data["until_position"]
	duration = 0.0


# 13. private methods: define all private methods here, use _ as preffix

# 14. subclasses: define all subclasses here
