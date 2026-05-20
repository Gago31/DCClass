@abstract
class_name Whiteboard
extends CanvasLayer

## Base class for the main whiteboard. Provides an interface of basic methods
## that any whiteboard should implement.

## Updates the subtitles of the whiteboard.
@abstract func update_subtitles(text: String) -> void;

## Returns the root widget of the class tree.
@abstract func get_class_root_widget() -> ClassRootWidget;

## Runs [method TreePostprocessing.postprocess] on the root widget.
@abstract func reprocess_tree() -> void;
