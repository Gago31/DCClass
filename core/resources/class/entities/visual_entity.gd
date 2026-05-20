@abstract
class_name VisualEntity
extends Entity

## An entity that is meant to have a visual representation in the whiteboard.
##
## A visual entity has a transform that allows it to be placed at a specific
## location inside the whiteboard, scaled, etc.

## The transform of this entity when it is instantiated in the class.
@export var transform: Transform2D

## The original transform of the entity, used inside the editor to keep a 
## reference to the initial value of [member transform] while making
## temporary changes.
var initial_transform: Transform2D
