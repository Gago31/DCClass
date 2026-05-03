@abstract
class_name NodeReferenceEntity
extends Entity

## A base class for entities that need to reference another node in the
## class tree.
##
## This can be used to modify the referenced [ClassNode] during the class or to
## call a method of a [ClassLeaf]'s entity.

## Emitted after setting the referenced node
signal reference_set

## The referenced ClassNode
@export var node_reference: ClassNode:
	set=set_reference

## Sets the node referenced by this entity. If you wish to override
## this method to run additional logic you should still call
## `super.set_reference()`, or manually emit `reference_set` in
## case your widget needs to be notified about changes to the reference.
func set_reference(node: ClassNode) -> void:
	node_reference = node
	reference_set.emit()

## Returns wether the given node is accepted by this entity.[br]
##
## For example, you can check if the node is a [ClassLeaf] or a [ClassGroup],
## or if the [ClassLeaf]'s entity is of a given type.
@abstract
func _is_node_valid(node: ClassNode) -> bool
