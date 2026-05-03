@abstract
class_name Whiteboard
extends CanvasLayer

@abstract func update_subtitles(text: String) -> void;

@abstract func get_class_root_widget() -> ClassRootWidget;

@abstract func reprocess_tree() -> void;
