class_name ClassLeaf
extends ClassNode


@export var entity: Entity = null


func get_class_name():
	return "ClassLeaf"

func get_editor_name() -> String:
	return entity.get_editor_name()

func is_leaf() -> bool:
	return true

func _setup_editor_tree_item(item: TreeItem) -> void:
	entity.config_editor_tree_item(item)

func get_printable_data() -> String:
	return entity.get_editor_name() 

func _on_value_updated_from_editor(item: TreeItem) -> void:
	entity.update_value(item)

func delete() -> void:
	entity.delete()
	deleted.emit()

func _to_string() -> String:
	return entity.get_editor_name()

func get_widget() -> PackedScene:
	return preload("uid://s6kfhuulr1sp")
