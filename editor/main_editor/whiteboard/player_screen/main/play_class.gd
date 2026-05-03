class_name ClassSceneEditor
extends Node2D

# This file contain the logic of the reproduction interface of the class.
# It is used to play the class, to seek nodes, to stop the class, etc

var WHITEBOARD_SIZE: Vector2i

#@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")
#@onready var _bus: EditorEventBus = Engine.get_singleton(&"EditorSignals")
@onready var _visual_system: VisualOutlineSystem

@export var class_index: ClassIndex


var tree_manager: TreeManagerEditor
var entry_point: NodeController

@onready var visual_widgets: Node2D = %VisualWidgets


func _enter_tree():
	WHITEBOARD_SIZE = _load_whiteboard_size()

#func _ready():
	#_bus.seek_node.connect(_seek_node)
	#_bus.seek_play.connect(_seek_play)

#func _setup_play():
	#class_index = PersistenceEditor.resources_class.class_index

	#if !_instantiate():
		#push_error("Error instantiating class: " + class_index.name)
		#return
#
	#print("play._ready")


func _load_whiteboard_size() -> Vector2i:
	return ProjectSettings.get_setting("display/whiteboard/size") as Vector2i


func _instantiate() -> bool:
	#NodeController.visual_widgets = visual_widgets
	#NodeController.push_slide_layer('BaseLayer')
	_visual_system = VisualOutlineSystem.new()
	add_child(_visual_system)
	return true

# To begin the reproduction from the entry point of the class.
#func _seek_play():
	#get_tree().call_group(&"skipped_before_play", "clear_before_play")
	#entry_point = PersistenceEditor.resources_class._current_node._node_controller
	#entry_point.play_seek()

# To seek a specific node in the class in an instant.
#func _seek_node(node_seek: ClassNode) -> void:
	#get_tree().call_group(&"widget_finished", "clear")
	#var node_seek_controller: NodeController = node_seek._node_controller
	##entry_point = PersistenceEditor.resources_class.root_tree_structure._node_controller
	#NodeController.clear_layers()
	#entry_point.seek(node_seek_controller, entry_point)
