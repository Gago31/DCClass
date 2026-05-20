@abstract
class_name Entity
extends Resource

## Base class for Entity types.
##
## An Entity contains data for an element or operation inside the class,
## it can define extra variables for a widget to use.

## Used inside the editor. Notifies that some variable of the entity
## has changed.
signal updated

## Used inside the editor. Notifies that the entity has been removed and
## triggers the deletion of its widget from the whiteboard.
signal deleted


## How long the entity is supposed to play, in seconds.[br][br]
##
## This doesn't necessarily reflect the actual time that the entity will
## play for, in particular for [Widget]s that have their 
## [code]play_mode[/code] set to [enum Widget.PlayMode.SYNC].
@export var duration: float = 0.0

## The corresponding item in the editor's control panel. You can use it to
## modify how the item is displayed after some change.
var _tree_item: TreeItem


## Returns the name of the entity's class.
## @deprecated
func get_class_name() -> String:
	return "Entity"

## Returns the name of this entity inside the editor.[br][br]
##
## The name should be understandable for a teacher, indicating clearly
## what type of entity this is and what it does.[br][br]
##
## If you need to show additional information about the entity, override the 
## method [method config_editor_tree_item] and use the second column (1) of the
## [TreeItem] to display it.
func get_editor_name() -> String:
	return "Unnamed entity"

## Sets the text of the [TreeItem] that represents this Entity inside the
## editor's control panel.[br][br]
##
## In general, you should use the item's column [code]0[/code] to display 
## the Entity's class name and any additional value or editable field should 
## be put in column [code]1[/code].[br][br]
##
## In case that you don't need to display any information besides the class
## name of the entity, you don't need to override this method. Instead, you
## should define [method get_editor_name] to return an appropriate name.
func config_editor_tree_item(item: TreeItem) -> void:
	_tree_item = item
	item.set_text(0, get_editor_name())

## Called when an editable field of the entity's [TreeItem] changes.[br]
## [b][color=indian_red]This method is used internally and you shouldn't 
## override it nor call it yourself.[/color][/b][br][br]
##
## To update a variable inside the entity after its item is updated, override
## [method _on_value_updated_from_editor].
func update_value(item: TreeItem) -> void:
	_on_value_updated_from_editor(item)
	updated.emit()

## You can override this method to run additional logic after an editable
## field changes from the editor's control panel.[br][br]
##
## In this method you should parse the [TreeItem]'s field value and
## set the entity's variable accordingly.
func _on_value_updated_from_editor(item: TreeItem) -> void:
	pass

func delete() -> void:
	deleted.emit()

## Returns the path of the entity's external resource, if any.[br][br]
##
## The path must be relative to the project's [code]assets[/code] folder, 
## for example an [AudioEntity] with a file named [code]001.ogg[/code] 
## should return [code]audio/001.ogg[/code].[br][br]
##
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
## You can also use the widget's scene path, but UID's are more stable.[br]
## If your widget calls an autoload or is referenced by one, you may have
## compiling problems. If that happens, using [method load] instead of
## [method preload] may help.
@abstract
func get_widget() -> PackedScene
