class_name GlobalWhiteboardManager
extends Node


@export var whiteboard_scene: PackedScene
@export var whiteboard_scene_desktop: PackedScene
@export var whiteboard_scene_mobile: PackedScene
@export var metadata: ClassMetadata
@export var root: ClassRoot

var _whiteboard: Whiteboard
var _whiteboard_window: Window
var _context_stack: Array[WhiteboardContext] = []
var ui: ClassWindowEditor

func _ready() -> void:
	push_context()

func get_root_widget() -> ClassRootWidget:
	if not _whiteboard:
		return null
	return _whiteboard.get_class_root_widget()

func go_to_whiteboard() -> void:
	get_tree().change_scene_to_packed(whiteboard_scene)

func detach_whiteboard() -> void:
	_whiteboard_window = Window.new()
	_whiteboard = whiteboard_scene.instantiate() as Whiteboard
	_whiteboard_window.add_child(_whiteboard)
	get_tree().root.add_child(_whiteboard_window)
	_whiteboard_window.close_requested.connect(_on_window_close_requested)

func close_whiteboard() -> void:
	if is_detached():
		_whiteboard_window.queue_free()
	_whiteboard_window = null

func is_detached() -> bool:
	return _whiteboard_window != null and is_instance_valid(_whiteboard_window)

func _on_window_close_requested() -> void:
	close_whiteboard()

func set_whiteboard(whiteboard: Whiteboard) -> void:
	_whiteboard = whiteboard

func update_subtitles(text: String) -> void:
	_whiteboard.update_subtitles(text)

func search_widget_by_entity(entity: Entity) -> Widget:
	return _whiteboard.get_class_root_widget().search_widget_by_entity(entity)

func search_widget_by_class_node(node: ClassNode) -> Widget:
	return _whiteboard.get_class_root_widget().search_widget_by_class_node(node)

func push_context() -> void:
	var new_context := WhiteboardContext.new()
	_context_stack.push_back(new_context)

func pop_context() -> void:
	_context_stack.pop_back()

func reset_context() -> void:
	_context_stack.clear()
	push_context()

func _get_context() -> WhiteboardContext:
	return _context_stack[_context_stack.size() - 1]

func set_pen_color(color: Color) -> void:
	_get_context().pen_color = color

func get_pen_color() -> Color:
	return _get_context().pen_color

func set_pen_thickness(value: float) -> void:
	_get_context().pen_thickness = value

func get_pen_thickness() -> float:
	return _get_context().pen_thickness

func clear_until(widget: Widget) -> void:
	_whiteboard.get_class_root_widget().clear_until(widget)

func set_playing(value: bool) -> void:
	if value:
		_whiteboard.get_class_root_widget().play()
	else:
		_whiteboard.get_class_root_widget().pause()

func reprocess_tree() -> void:
	if not _whiteboard: return
	_whiteboard.reprocess_tree()
