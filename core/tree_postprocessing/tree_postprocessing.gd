class_name TreePostprocessing
extends Node


@export var postprocessors: Array[TreePostprocessor] = []
#var _running := false

func postprocess(root: ClassRootWidget) -> void:
	#if _running:
		#print("Tried to reprocess tree while already running")
	#_running = true
	_reset_state()
	_process_widget(root)
	print("fake update")
	root.updated.emit()
	#_running = false

func _process_widget(widget: Widget) -> void:
	if widget is not EntityWidget:
		for child in widget.get_children() as Array[Widget]:
			_process_widget(child)
	for p in postprocessors:
		p.process_widget(widget)

func _reset_state() -> void:
	for p in postprocessors:
		p.reset()
