class_name CoreEventBus
extends Node

# This bus is used to communicate the core events in the application.


# Emitted when the current node in the index tree changes and the new node is passed as an argument.
signal current_node_changed(current_node: ClassNode)

# Emitted when the tree is finished playing.
signal tree_play_finished()

# Emitted when the stop_widget call to stop the playback.
signal stop_widget()

# Emitted when the pause_widget call to pause the playback. In this case, is equal to stop_widget.
signal pause_playback_widget()

signal subtitles_updated(text: String)
