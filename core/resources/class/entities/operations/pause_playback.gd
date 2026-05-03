# 1. class name: fill the class name
class_name PausePlaybackEntity
extends Entity

# 2. docs: use docstring (##) to generate docs for this file
## Represents an infinite pause

# 3. signals: define signals here

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here

# 7. public variables: define all public variables here

# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here
func _init() -> void:
	entity_id = "PausePlayback"


# 11. virtual methods: define other virtual methos here
func get_class_name() -> String:
	return "PausePlaybackEntity"

func get_editor_name() -> String:
	return "Pause"

func get_widget() -> PackedScene:
	return preload("uid://bjangwmut685w")

### Returns a dictionary representation of this entity.
#func serialize() -> Dictionary:
	#return {
		#"entity_id": entity_id,
		#"entity_type": get_class_name()
	#}
#
### Returns a new instance of this entity type from the given dictionary(.json).
#static func deserialize(data: Dictionary) -> Entity:
	#assert(CustomClassDB.class_exists(data["entity_type"]), "Entity type does not exist: " + data["entity_type"])
	#var instance = CustomClassDB.instantiate(data["entity_type"])
	#instance.entity_id = data["entity_id"]
	#instance.load_data(data)
	#return instance

### Loads data from a dictionary into this entity.
#func load_data(_data: Dictionary) -> void:
	#pass

### Returns a temporary copy of this entity.
#func copy_tmp() -> Entity:
	#var new_entity: Entity = CustomClassDB.instantiate(get_class_name())
	#new_entity.load_data(serialize())
	#return new_entity

# Deletes this entity.:


# Serialize to a dictionary format(.json) for saving.
#func serialize() -> Dictionary:
	#return {
		#"entity_id": entity_id,
		#"entity_type": get_class_name(),
		#"duration": duration
	#}

# Load data from a dictionary format(.json) to resource(PausePlaybackEntity).
#func load_data(data: Dictionary) -> void:
	#pass

func config_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, get_editor_name())

# 12. public methods: define all public methods here

# 13. private methods: define all private methods here, use _ as preffix

# 14. subclasses: define all subclasses here
