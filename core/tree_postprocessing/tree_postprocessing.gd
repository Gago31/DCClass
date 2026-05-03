class_name TreePostprocessing
extends Node


@export var postprocessors: Array[TreePostprocessor] = []


func postprocess(root: ClassRootWidget) -> void:
	_reset_state()
	_process_widget(root)

func _process_widget(widget: Widget) -> void:
	if widget is not EntityWidget:
		for child in widget.get_children() as Array[Widget]:
			_process_widget(child)
	for p in postprocessors:
		p.process_widget(widget)

func _reset_state() -> void:
	for p in postprocessors:
		p.reset()
