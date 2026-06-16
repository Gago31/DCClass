class_name ClassWindowPlayer
extends WhiteboardUI


@export var dark_mode_theme: Theme
@export var light_mode_theme: Theme
var show_index_tree := false
var subtitles_on := false
var _subtitles_lookup: Array[SubtitleWidget] = []
var _current_subtitle: SubtitleWidget
@onready var index_tree: Tree = %IndexTree
@onready var index_tree_panel: PanelContainer = %IndexTreePanel


func _ready():
	super._ready()
	build_index_tree(WhiteboardManager.root)
	update_subtitles_visibility()
	class_root.resumed.connect(update_subtitles_visibility)
	class_root.started_playing.connect(update_subtitles_visibility)
	class_root.paused.connect(update_subtitles_visibility)
	class_root.finished_playing.connect(update_subtitles_visibility)
	_collect_subtitles(class_root)

func build_index_tree(root: ClassRoot) -> void:
	_build_index_node(root, null)

func _build_index_node(node: ClassNode, parent: TreeItem) -> void:
	if node.is_leaf(): return
	var item := index_tree.create_item(parent)
	var group_node := node as ClassGroup
	item.set_metadata(0, group_node)
	item.set_text(0, group_node._name)
	for child in group_node.children:
		_build_index_node(child, item)

func _on_index_tree_item_selected() -> void:
	var selected_item := index_tree.get_selected()
	var group_node := selected_item.get_metadata(0) as ClassGroup
	var widget := class_root.search_widget_by_class_node(group_node)
	class_root.jump_to_widget(widget)

func _on_index_button_pressed() -> void:
	show_index_tree = !show_index_tree
	if show_index_tree:
		index_tree_panel.show()
		create_tween().tween_property(
			index_tree_panel, 
			"custom_minimum_size", 
			Vector2(250, 0), 
			0.2
		)
	else:
		var tween := create_tween().tween_property(
			index_tree_panel, 
			"custom_minimum_size", 
			Vector2.ZERO, 
			0.2
		)
		await tween.finished
		index_tree_panel.hide()

func _set_current_item(item: TreeItem, is_current: bool) -> void:
	item.set_custom_color(0, Color.LIME_GREEN if is_current else Color.GRAY)

func _on_subtitles_button_toggled(toggled_on: bool) -> void:
	subtitles_on = toggled_on
	update_subtitles_visibility()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"next_subtitle"):
		_next_subtitle()
	elif event.is_action_pressed(&"prev_subtitle"):
		_prev_subtitle()

func collect_subtitles(root: ClassRootWidget) -> void:
	_collect_subtitles(root)

func _collect_subtitles(node: ClassNodeWidget) -> void:
	if node.is_leaf():
		var leaf := node as ClassLeafWidget
		if leaf.widget is SubtitleWidget:
			_subtitles_lookup.append(leaf.widget)
			leaf.widget.finished_playing.connect(_set_current_subtitle.bind(leaf.widget))
	else:
		var group := node as ClassGroupWidget
		for child in group.get_children() as Array[ClassNodeWidget]:
			_collect_subtitles(child)

func _set_current_subtitle(widget: SubtitleWidget) -> void:
	_current_subtitle = widget

func _next_subtitle() -> void:
	var index := _find_current_subtitle_index()
	if index >= _subtitles_lookup.size() - 1: return
	_current_subtitle = _subtitles_lookup[index + 1]
	class_root.jump_to_widget(_current_subtitle)

func _prev_subtitle() -> void:
	var index := _find_current_subtitle_index()
	if index <= 0: return
	_current_subtitle = _subtitles_lookup[index - 1]
	class_root.jump_to_widget(_current_subtitle)

func _find_current_subtitle_index() -> int:
	if not _current_subtitle: return -1
	return _subtitles_lookup.find(_current_subtitle)

func update_subtitles_visibility() -> void:
	if class_root.is_playing() and not subtitles_on:
		subtitles.hide()
	else:
		subtitles.show()


func _on_theme_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		WhiteboardManager.set_whiteboard_theme(light_mode_theme)
	else:
		WhiteboardManager.set_whiteboard_theme(dark_mode_theme)


func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	WhiteboardManager.toggle_fullscreen()
