class_name TreePostprocessing
extends Node

## A node that processes the class tree widgets after the tree is built.
##
## It can be used to calculate values useful for the playback without having
## to store them in the class file.

## A list of the postprocessing scripts.[br][br]
##
## The scripts are run in order, you should keep this in mind in case a script
## needs a variable that is calculated in another (like start and end times).[br][br]
##
## You should set the postprocessing scripts inside the [TreePostprocessing] 
## scene to keep consistency.
@export var postprocessors: Array[TreePostprocessor] = []

## Starts the postprocessing.
func postprocess(root: ClassRootWidget) -> void:
	_reset_state()
	_process_widget(root)
	root.updated.emit()

## Runs the postprocessing scripts for a [Widget]'s children and then itself, 
## in a depth-first order.
func _process_widget(widget: Widget) -> void:
	if widget is not EntityWidget:
		for child in widget.get_children() as Array[Widget]:
			_process_widget(child)
	for p in postprocessors:
		p.process_widget(widget)

## Resets the state for all [TreePostprocessor]s.
func _reset_state() -> void:
	for p in postprocessors:
		p.reset()
