class_name WhiteboardContext
extends Resource

## A resource that keeps track of the whiteboard's current pen color and size.
##
## Each [ClassGroup] introduces a new context into a stack, and the one at
## the top of the stack will be used to setup all the lines that are drawn.
##
## The whiteboard context will be used inside the editor and while building the
## class tree inside the Player. It won't have any effect during playback.

@export var pen_color := Color.WHITE
@export var pen_thickness: float = 3
