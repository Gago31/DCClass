class_name NodeController
extends Node

static var root_node_controller: Node # This is the root node for all node controllers.
static var visual_widgets: Node2D # This is the root node for visual slides/widgets. Used for the visuals elements in the whiteboard.
static var visual_slide: Node2D # This is a slide for visual widgets.
static var slide_layers: Array[Node2D] # This is a stack to hold the visual slide layers.
static var current_layer_index: int = -1
static var audio_widgets: Node2D # This is the root node for audio widgets.

@export var _class_node: ClassNode

#@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")

# hotfix tmp: should remove editor bus dependancy
#var _bus: EditorEventBus
#func _ready() -> void:
	#if Engine.has_singleton(&"EditorSignals"):
		#_bus = Engine.get_singleton(&"EditorSignals") as EditorEventBus


# Add the controller to the root node controller.
func _add_child_root() -> void:
	root_node_controller.add_child(self)

# Delete the controller and free the resources.
func self_delete() -> void:
	queue_free()

# Skip to the end of the widget.
func skip_to_end() -> void:
	pass

# Add a new slide layer to the stack
static func push_slide_layer(layer_name:= 'SlideLayer') -> Node2D:
	var new_layer = Node2D.new()
	new_layer.name = layer_name
	visual_widgets.add_child(new_layer)
	slide_layers.append(new_layer)
	current_layer_index += 1
	visual_slide = new_layer
	return new_layer

# Pop the last slide layer from the stack
static func pop_slide_layer() -> void:
	if current_layer_index >= 0:
		var layer_to_remove = slide_layers[current_layer_index]
		visual_widgets.remove_child(layer_to_remove)
		slide_layers.remove_at(current_layer_index)
		current_layer_index -= 1
		layer_to_remove.queue_free()

		if current_layer_index >= 0:
			visual_slide = slide_layers[current_layer_index]
		else:
			visual_slide = null

# Hide all slide layers (useful for clear widget on a slide)
static func hide_layers() -> void:
	for layer in slide_layers:
		layer.hide()

# Unhide all slide layers (useful for exiting a slide)
static func unhide_layers() -> void:
	for layer in slide_layers:
		layer.show()

static func get_current_layer() -> Node2D:
	if current_layer_index >= 0 and current_layer_index < slide_layers.size():
		return slide_layers[current_layer_index]
	return visual_slide

static func clear_layers() -> void:
	while NodeController.current_layer_index >= 0:
		var layer_to_remove = slide_layers[current_layer_index]
		slide_layers.remove_at(current_layer_index)
		current_layer_index -= 1
		if is_instance_valid(layer_to_remove):
			visual_widgets.remove_child(layer_to_remove)
			layer_to_remove.queue_free()

	slide_layers.clear()
	current_layer_index = -1
	push_slide_layer('BaseLayer')
	
static func get_visible_nodes() -> Array[ClassLeaf]:
	var nodes: Array[ClassLeaf] = []
	for sl: Node2D in slide_layers:
		for widget: Widget in sl.get_children():
			nodes.append(widget.class_node)
	return nodes

func clear_before_play() -> void:
	remove_from_group(&"skipped_before_play")
