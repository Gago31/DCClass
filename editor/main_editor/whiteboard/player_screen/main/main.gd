class_name ClassUIEditor
extends Whiteboard

@onready var window: ClassWindowEditor = %ClassWindow
@onready var tree_postprocessing: TreePostprocessing = %TreePostprocessing


func _ready():
	WhiteboardManager.set_whiteboard(self)

func update_subtitles(text: String) -> void:
	window.set_subtitles(text)

func get_class_root_widget() -> ClassRootWidget:
	return window.class_root

func reprocess_tree() -> void:
	tree_postprocessing.postprocess(get_class_root_widget())
