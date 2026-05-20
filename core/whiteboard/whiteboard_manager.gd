class_name GlobalWhiteboardManager
extends Node

## Autoload that allows multiple parts of the app to interact with the whiteboard.
## 
## Its autoload name is [code]WhiteboardManager[/code].

## Emmitted when the pen or mouse starts drawing on the whiteboard's canvas.
signal pen_pressed
## Emmitted when the pen or mouse stops drawing on the whiteboard's canvas.
signal pen_lifted

@export var whiteboard_scene: PackedScene
@export var whiteboard_scene_desktop: PackedScene
@export var whiteboard_scene_mobile: PackedScene
## The resource with the loaded class' metadata.
@export var metadata: ClassMetadata
## The resource with the loaded class tree.
@export var root: ClassRoot

var _whiteboard: Whiteboard
var _whiteboard_window: Window
var _context_stack: Array[WhiteboardContext] = []
var ui: WhiteboardUI

func _ready() -> void:
	push_context()

## Returns the root widget of the class tree.[br]
## If you want the resource instead, use [member root].
func get_root_widget() -> ClassRootWidget:
	if not _whiteboard:
		return null
	return _whiteboard.get_class_root_widget()

## Changes the current scene to a standalone whiteboard. Used in the Player.
func go_to_whiteboard() -> void:
	get_tree().change_scene_to_packed(whiteboard_scene)

## Creates a new separate window with a whiteboard. Used in the editor.
func detach_whiteboard() -> void:
	if is_detached(): return
	_whiteboard_window = whiteboard_scene.instantiate() as WindowWhiteboard
	get_tree().root.add_child(_whiteboard_window)
	_whiteboard_window.close_requested.connect(_on_window_close_requested)

## Closes the detached whiteboard.
func close_whiteboard() -> void:
	if is_detached():
		_whiteboard_window.queue_free()
	_whiteboard_window = null

## Wether the whiteboard is in a detached state.
func is_detached() -> bool:
	return _whiteboard_window != null and is_instance_valid(_whiteboard_window)

func _on_window_close_requested() -> void:
	close_whiteboard()

## Sets the current whiteboard. Called by the [Whiteboard] upon creation.
func set_whiteboard(whiteboard: Whiteboard) -> void:
	_whiteboard = whiteboard

## Updates the subtitles on the current whiteboard.
func update_subtitles(text: String) -> void:
	if not _whiteboard: return
	_whiteboard.update_subtitles(text)

## Returns an [EntityWidget] inside the class tree that has [param entity] as 
## its assigned entity.
func search_widget_by_entity(entity: Entity) -> EntityWidget:
	return get_root_widget().search_widget_by_entity(entity)

## Returns a [ClassNodeWidget] that has [param node] as its assigned class node.
func search_widget_by_class_node(node: ClassNode) -> Widget:
	return get_root_widget().search_widget_by_class_node(node)

## Pushes a new [WhiteboardContext] into the context stack.
func push_context() -> void:
	var new_context := WhiteboardContext.new()
	_context_stack.push_back(new_context)

## Pops the current [WhiteboardContext] from the context stack.
func pop_context() -> void:
	_context_stack.pop_back()

## Clears the context stack of the whiteboard.
func reset_context() -> void:
	_context_stack.clear()
	push_context()

## Sets the pen color for the current [WhiteboardContext].
func set_pen_color(color: Color) -> void:
	_get_context().pen_color = color

## Gets the pen color of the current [WhiteboardContext].
func get_pen_color() -> Color:
	return _get_context().pen_color

## Sets the pen size for the current [WhiteboardContext].
func set_pen_thickness(value: float) -> void:
	_get_context().pen_thickness = value

## Gets the pen size of the current [WhiteboardContext].
func get_pen_thickness() -> float:
	return _get_context().pen_thickness

## Clears the contents of whiteboard until the given widget (usually a
## [ClearWidget].
func clear_until(widget: Widget) -> void:
	get_root_widget().clear_until(widget)

## Shortcut method to set the class as playing or paused.
func set_playing(value: bool) -> void:
	if value:
		get_root_widget().play()
	else:
		get_root_widget().pause()

## Forces the [TreePostprocessor] to reprocess the class tree. Used in the editor
## after an update to the tree.
func reprocess_tree() -> void:
	if not _whiteboard: return
	_whiteboard.reprocess_tree()

## Tells the whiteboard manager to emit the signal [signal pen_pressed].
func notify_started_drawing() -> void:
	pen_pressed.emit()

## Tells the whiteboard manager to emit the signal [signal pen_lifted].
func notify_stopped_drawing() -> void:
	pen_lifted.emit()

func _get_context() -> WhiteboardContext:
	return _context_stack[_context_stack.size() - 1]
