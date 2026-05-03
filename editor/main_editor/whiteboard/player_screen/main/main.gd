class_name ClassUIEditor
extends Whiteboard

#static var context: ClassContextEditor = ClassContextEditor.new()

#@onready var class_scene: ClassSceneEditor = %PlayClass
@onready var window: ClassWindowEditor = $ClassWindow
@onready var tree_postprocessing: TreePostprocessing = %TreePostprocessing


func _ready():
	WhiteboardManager.set_whiteboard(self)
	#class_scene._setup_play()
	#print("ClassScene._ready")
	#_setup_scene()

#func _setup_scene():
	#window.set_class_node(class_scene)

#class ClassContextEditor:
	#var camera: ClassCameraEditor

func update_subtitles(text: String) -> void:
	window.set_subtitles(text)

func get_class_root_widget() -> ClassRootWidget:
	return window.class_root

func reprocess_tree() -> void:
	tree_postprocessing.postprocess(get_class_root_widget())
