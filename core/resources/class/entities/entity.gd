@abstract
class_name Entity
extends Resource

## Base class for Entity types


signal deleted
signal updated


@export var duration: float = 0.0
var entity_id
var resource_ready := true


## Returns the id of this entity.
func get_entity_id():
	return entity_id

## Returns the name of the class.
func get_class_name() -> String:
	return "Entity"

## Returns the name of this entity.
func get_editor_name() -> String:
	return "Unnamed entity"

#@abstract
#func get_play_mode() -> PlayMode



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

# Deletes this entity.
func self_delete() -> void:
	pass

# Converts a temporary entity to a persistent entity.
func tmp_to_persistent() -> void:
	pass

func save_resource(path: String) -> String:
	return ""

func config_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, get_editor_name())

func update_value(item: TreeItem) -> void:
	_on_value_updated_from_editor(item)
	updated.emit()

func _on_value_updated_from_editor(item: TreeItem) -> void:
	pass

func delete() -> void:
	deleted.emit()

## Returns the path of the entity's external resource, if any.[br]
## The path must be relative to the project's `assets` folder, for example
## an [AudioEntity] with a file named `001.ogg` should return `audio/001.ogg`.[br]
## An entity without external resources should not define this method.
func get_resource_path() -> String:
	return ""

## Returns the scene corresponding to the entity's widget.[br]
##
## It should look something like this for all entities.
##
## [codeblock]
## func get_widget() -> PackedScene:
## 	return preload("uid://widgetuid")
## [/codeblock]
##
## You can also use the widget's scene path, but UID's are more stable.
@abstract
func get_widget() -> PackedScene
