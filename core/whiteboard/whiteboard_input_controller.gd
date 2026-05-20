@abstract
class_name WhiteboardInputController
extends Control


var _dragging: bool = false


@onready var _viewport: SubViewport = %SubViewport
@onready var camera: ClassCameraEditor = %Camera2D


func _gui_input(event: InputEvent):
	_handle_screen_dragging(event)

## Defines how the whiteboard should handle inputs to move the camera across the 2D space.
@abstract
func _handle_screen_dragging(event: InputEvent) -> void;
