class_name ClassWindowEditor
extends WhiteboardUI


func _ready():
	super._ready()
	class_root.child_added.connect(_on_tree_modified)
