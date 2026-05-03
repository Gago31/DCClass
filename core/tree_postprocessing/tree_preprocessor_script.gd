@abstract
class_name TreePostprocessor
extends Resource

## Base class for tree postprocessing nodes.[br]
## Extend this class to write postprocessing scripts to 

## Determines which [Widget]s will be processed by this preprocessor, and
## which it will skip.[br]
## Any widget for which this method returns `true` will be passed to
## [method _process_widget].
@abstract func is_widget_valid(widget) -> bool;

## Process a valid widget of the tree, in a depth-first order.[br]
##
## [EntityWidget]s will be processed first, then their [ClassLeafWidget]s, 
## and once all the nodes in a [ClassGroupWidget] or [ClassSlideWidget] are 
## processed, you will process the group or slide itself).[br]
##
## You can keep additional state if you need to, and it will be preserved
## between calls to this method.
@abstract func _process_widget(widget: Widget) -> void;

## Resets the state of the postprocessor. If you are not using extra
## variables inside your postprocessor, you can leave this empty.
@abstract func reset() -> void;

## Process a valid [Widget].
## [color=indian_red][b]Don't override this method[/b][/color]
func process_widget(widget: Widget) -> void:
	if is_widget_valid(widget):
		_process_widget(widget)
