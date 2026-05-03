class_name SubtitleEntity
extends Entity

# 2. docs: use docstring (##) to generate docs for this file
## An [Entity] that holds a reference to an image file.

# 3. signals: define signals here

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here
@export var text: String
# 7. public variables: define all public variables here

# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here
func _init() -> void:
	entity_id = "Subtitle"

func get_class_name() -> String:
	return "SubtitleEntity"

func get_editor_name() -> String:
	return "Subtitles: %s" % text

func get_widget() -> PackedScene:
	return preload("uid://cgvc74n6rdute")

#func serialize() -> Dictionary:
	#return {
		#"entity_id": entity_id,
		#"entity_type": get_class_name(),
		#"text": text
	#}

#func load_data(data: Dictionary) -> void:
	#text = data["text"]
	#duration = 0.0

func config_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, "Subtitle:")
	item.set_text(1, text)
	item.set_editable(1, true)

func _on_value_updated_from_editor(item: TreeItem) -> void:
	var new_text := item.get_text(1)
	text = new_text

# 13. private methods: define all private methods here, use _ as preffix

# 14. subclasses: define all subclasses here
