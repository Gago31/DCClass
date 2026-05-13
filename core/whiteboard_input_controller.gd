@abstract
class_name WhiteboardInputController
extends Control

const WARP_OFFSET := -10

var _dragging: bool = false
var _warped: bool = false

@onready var _viewport: SubViewport = %SubViewport
@onready var camera: ClassCameraEditor = %Camera2D


func _gui_input(event):
	_handle_screen_dragging(event)

@abstract
func _handle_screen_dragging(event: InputEvent) -> void;
