# 1. class name: fill the class name
class_name ClassLeaf
extends ClassNode

# 2. docs: use docstring (##) to generate docs for this file


# 3. signals: define signals here
signal property_updated(property: EntityProperty)


# 4. enums: define enums here


# 5. constants: define constants here
static var entities: Dictionary

# 6. export variables: define all export variables in groups here

# The entity associated with this ClassLeaf.
@export var entity: Entity = null

# The properties of the entity associated with this ClassLeaf.
@export var entity_properties: Array[EntityProperty] = []

# 7. public variables: define all public variables here

# The unique identifier for the entity. Can be an int or a string.
# Ideally use a string for Operations and a int for dynamic entities.
var entity_id


# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here


func get_class_name():
	return "ClassLeaf"

func get_editor_name() -> String:
	return entity.get_editor_name()

# Serialize to a dictionary format(.json) for saving.
#func serialize() -> Dictionary:
	#return {
		#"type": get_class_name(),
		#"entity_id": entity_id,
		#"entity_properties": entity_properties.map(func(p): return p.serialize()),
	#}

# Deserialize from a dictionary format(.json) to resource(ClassLeaf).
#static func deserialize(data: Dictionary) -> ClassLeaf:
	#var instance: ClassLeaf = ClassLeaf.new()
	#instance.entity_id = data["entity_id"]
	#instance.entity = entities[instance.entity_id]
	#for property_data in data["entity_properties"]:
		#instance.entity_properties.append(EntityProperty.deserialize(property_data))
	#return instance

# Setup the controller associated with this ClassLeaf.
#func _setup_controller(is_child_root: bool) -> void:
	#var _class: String = get_class_name().replace("Class", "") + "Controller"
	#assert(CustomClassDB.class_exists(_class), "Class " + _class + " does not exist.")
	#var controller: LeafController = CustomClassDB.instantiate(_class)
#
	#_node_controller = controller
	#controller._setup(self)
	#if is_child_root:
		#controller._add_child_root()

## Return a dictionary with all the properties of the entity.
## Keys with the same name will be overwritten.
func get_properties() -> Dictionary:
	var _properties: Dictionary = {}
	for property in entity_properties:
		var _prop: Dictionary = property.get_property()
		_properties.merge(_prop, true)
	return _properties
	
## Get a specific property by its type
func get_property_by_type(property_type: String) -> EntityProperty:
	for property in entity_properties:
		if property.get_class_name() == property_type:
			return property
	return EntityProperty.new()

## Set a specific property
func set_property(property: EntityProperty) -> void:
	var property_type: String = property.get_class_name()
	var data: Dictionary = property.get_property()
	var existing_property: EntityProperty = null
	
	# Search for the prop in props dict
	for prop: EntityProperty in entity_properties:
		if prop.get_class_name() == property_type:
			existing_property = prop
			break
	
	# If isnt exist, create
	if existing_property == null:
		existing_property = property
		entity_properties.append(existing_property)
	else:
		existing_property.set_property(data)
	
	property_updated.emit(property)


# Delete this ClassLeaf and its associated entity.
func self_delete() -> void:
	# Check if is a dynamic entity.
	if (entity_id is int or entity_id is float) and entity_id in entities:
		entity.self_delete()
		entities.erase(entity_id)
	
	if _parent == null:
		return
	_parent.child_delete(self)
	_node_controller.self_delete()

# Create a copy of this ClassLeaf with its entity and properties.
func copy_tmp() -> ClassLeaf:
	var new_leaf: ClassLeaf = ClassLeaf.new()
	new_leaf.entity = entity.copy_tmp()
	new_leaf.entity_properties = []
	for property in entity_properties:
		new_leaf.entity_properties.append(property.copy_tmp())
	return new_leaf

func is_leaf() -> bool:
	return true

func _setup_editor_tree_item(item: TreeItem) -> void:
	entity.config_editor_tree_item(item)

func get_printable_data() -> String:
	return entity.get_editor_name() 

func update_value(item: TreeItem) -> void:
	entity.update_value(item)

func delete() -> void:
	entity.delete()
	deleted.emit()

func _to_string() -> String:
	return entity.get_editor_name()

func get_widget() -> PackedScene:
	return preload("uid://s6kfhuulr1sp")

# Serialize to a dictionary format(.json) for saving.:

# 13. private methods: define all private methods here, use _ as preffix
func _validate():
	pass
	
# 14. subclasses: define all subclasses here
