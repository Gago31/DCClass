@abstract
class_name Widget
extends Node2D

## A widget is a visual element that can be played and reset.
## This class defines the main API for a widget.


## The state in which a widget is currently.
enum PlayState {
	STOPPED, ## The widget hasn't begun playing yet.
	PLAYING, ## The widget is currently playing.
	PAUSED, ## The widget already began playing, and it was paused.
	FINISHED, ## The widget has finished playing.
	## The widget is in the middle of seeking.[br]This is an intermediate state
	## that will not last until the end of the frame, but you can use
	## [method is_seeking] during [method _on_skip] and [method _on_reset] to
	## check wether those methods are being called during normal playback or
	## during a seek operation.
	SEEKING 
}

## The different ways in which a widget can be played during the class.
enum PlayMode {
	## Calls [code]play()[/code] and continues immediately. Useful for operations
	## and spawning elements.
	INSTANT, 
	## Plays the widget synchronized with the current playing node. Multiple of
	## these in succession will share the total time to finish at the same time
	## as the reference node.[br]
	## This is meant to be used with lines.
	SYNC,
	## Starts playing the widget and then plays any [code]INSTANT[/code] and 
	## [code]SYNC[/code] widgets that follow. This widget's duration will be 
	## used as the reference time for [code]SYNC[/code] widgets.[br]
	## This mode is mostly used with audio.
	PLAY_AND_ADVANCE,
	## Starts playing the widget and doesn't continue until it finishes.[br]
	## Mostly used for playing videos.
	PLAY_AND_WAIT
}

## Emitted when the widget starts playing from a `STOPPED` state.
signal started_playing
## Emitted when the widget finishes playing.
signal finished_playing
## Emitted when the widget gets paused.
signal paused
## Emitted when the widget starts playing from a `PAUSED` state.
signal resumed
## Emitted when a widget is modified from the editor.[br]
## This signal propagates up the tree until reaching the [ClassRootWidget].
signal updated


## How long the widget has been playing for.[br][br]
##
## If the widget is being played at a different speed than [code]1.0[/code],
## [code]play_time[/code] won't reflect the real playtime, but the playtime 
## multiplied by the playback speed.[br][br]
##
## You can use this variable to know at which point of its playback the widget
## is relative to its duration.
var play_time: float = 0.0
## How long the widget should play for.[br][br]
##
## This variable is usually set from the widget's [Entity] for [ClassLeafWidget]s
## or calculated from its children for [ClassGroupWidget]s.[br][br]
##
## For widgets with a [code]play_mode[/code] of [enum PlayMode.SYNC], 
## the duration doesn't represent the real playback duration but how long they 
## will play relative to other [code]SYNC[/code] nodes in its group.
var duration: float = -1.0:
	get=get_duration
## The time in seconds into the class at which this widget begins playing.
var start_time: float = 0.0
## The time in seconds into the class at which this widget ends playing.
var end_time: float = 0.0
var _play_speed: float = 1.0
var _play_state: PlayState = PlayState.STOPPED


func _process(delta: float) -> void:
	if _play_state != PlayState.PLAYING: return
	play_time += delta * _play_speed
	_while_playing(delta)

## Use this method to initialize the widget.[br][br]
##
## [method setup] is run at the start when the class is loaded, so you should 
## use it to load external resources or preprocess data, you can't rely on 
## runtime variables or other nodes here. Use [method Widget._on_started_playing]
## if you need to access the state of the program or reference other widgets.
func setup() -> void:
	pass

## Starts playing the widget, or resumes playback if it is paused.[br][br]
##
## [color=indian_red][b]You shouldn't override this method.[/b][/color][br][br]
##
## Check [method Widget._on_started_playing], [method Widget._on_unpaused] and
## [method Widget._while_playing] if you need to run logic for when the widget
## starts playing.
func play(speed: float = 1.0) -> void:
	match _play_state:
		PlayState.STOPPED:
			_play_speed = speed
			_set_play_state(PlayState.PLAYING)
			_on_started_playing()
			started_playing.emit()
		PlayState.PAUSED:
			_play_speed = speed
			_set_play_state(PlayState.PLAYING)
			_on_unpaused()
			resumed.emit()
		PlayState.FINISHED:
			finish_playing()

## Pauses the widget if it is playing.[br][br]
##
## [color=indian_red][b]You shouldn't override this method.[/b][/color][br][br]
##
## Check [method Widget._on_paused] if you need to run logic for when the 
## widget gets paused.
func pause() -> void:
	_set_play_state(PlayState.PAUSED)
	_on_paused()
	paused.emit()

## Stops this widget, resetting it to its initial state as if it hasn't begun
## playing yet.
func stop() -> void:
	pause()
	reset()

## Jumps to a [param time] within the widget's play time, in total seconds
## from the beggining of the class.[br][br]
##
## [color=indian_red][b]You shouldn't override this method.[/b][/color][br][br]
##
## If the given time is before this widget is meant to start playing, it will
## be reset, and if the time is after it has to finish playing, it will skip
## to its end state.[br][br]
##
## If [param playing] is [code]fals[/code], the class will pause after seeking,
## if it is [code]true[/code], it will start playing from [param time].[br][br]
##
## To define the specific behavior of a widget when seeking to a time in the
## middle of playing, override [method _on_seek].
func seek(time: float, playing: bool = false) -> void:
	if time <= start_time:
		return reset()
	if time >= end_time:
		return jump_to_end()
	if get_play_mode() == PlayMode.SYNC:
		var effective_duration := end_time - start_time
		var sync_speed := duration / effective_duration
		play_time = (time - start_time) * sync_speed
	else:
		play_time = time - start_time
	_set_play_state(PlayState.PLAYING if playing else PlayState.PAUSED)
	_on_seek()

## Resets the widget to its initial state.
##
## [color=indian_red][b]You shouldn't override this method.[/b][/color][br][br]
##
## To define how the widget should reset itself, override [method _on_reset].
func reset() -> void:
	play_time = 0.0
	_set_play_state(PlayState.STOPPED)
	_on_reset()

## Skips until the end of the widget, setting it to the state that it should
## have after it has finished playing.
##
## [color=indian_red][b]You shouldn't override this method.[/b][/color][br][br]
##
## To define how this widget should behave when it is skipped, override
## [method _on_skip].
func jump_to_end() -> void:
	play_time = duration
	_on_skip()
	finish_playing()

## Returns the total duration of this widget in seconds.
func get_duration() -> float:
	if duration < 0.0:
		duration = _calculate_duration()
	return duration

## Makes the widget finish playing, runs all the necessary ending logic and
## notifies that it has ended by emitting the signal [signal finished_playing].
func finish_playing() -> void:
	_on_finished_playing()
	_set_play_state(PlayState.FINISHED)
	finished_playing.emit()

## Wether the widget is currently playing.
func is_playing() -> bool:
	return _play_state == PlayState.PLAYING

## Wether the widget is currently paused. This means that it already started
## playing and got paused before finishing.
func is_paused() -> bool:
	return _play_state == PlayState.PAUSED

## Wether the widget is currently stopped. This means that it has not begun
## playing yet.
func is_stopped() -> bool:
	return _play_state == PlayState.STOPPED

## Wether the widget already finished playing.
func is_finished() -> bool:
	return _play_state == PlayState.FINISHED

## Wether the widget is currently seeking. This will almost always return
## [code]false[/code], except when inside the methods [method _on_reset] and
## [method _on_skip] when they're called while attempting to seek.
func is_seeking() -> bool:
	return _play_state == PlayState.SEEKING

## Returns the [enum PlayMode] of the widget.
@abstract func get_play_mode() -> PlayMode;

## Tries to find an [EntityWidget] in the tree that has [param value] as its
## entity.
@abstract func search_widget_by_entity(value: Entity) -> EntityWidget;

## Computes how long the widget should play for, if it hasn't already.
@abstract func _calculate_duration() -> float;

## Run here the logic necessary for when the widget starts playing.[br]
func _on_started_playing() -> void:
	pass

## Run here the logic for when the widget is paused.
func _on_paused() -> void:
	pass

## Run here the logic for when the widget is paused.
func _on_unpaused() -> void:
	pass

## Run here the logic for when the widget finishes playing.
func _on_finished_playing() -> void:
	pass

## Run here the logic meant to be run every frame while playing.[br]
## Useful for widgets that need to determine their appearance based on
## their play time.
func _while_playing(delta: float) -> void:
	pass

## This method runs after a node's playtime has been altered during a seek
## operation.[br] This won't be called if the user seeks to a point before the
## widget starts playing or after it finishes, only if the user seeks to a
## point in the middle of the widget's playtime.
func _on_seek() -> void:
	pass

## Use this method to reset the widget to its default state, by resetting
## variables, hiding visual elements, etc.
func _on_reset() -> void:
	pass

## Use this method to set the widget to its final state, after it has finished
## playing.
func _on_skip() -> void:
	pass

func _set_play_state(play_state: PlayState) -> void:
	_play_state = play_state
	match _play_state:
		PlayState.PLAYING:
			process_mode = Node.PROCESS_MODE_ALWAYS
		PlayState.PAUSED:
			process_mode = Node.PROCESS_MODE_DISABLED
		PlayState.STOPPED:
			process_mode = Node.PROCESS_MODE_DISABLED
		PlayState.FINISHED:
			process_mode = Node.PROCESS_MODE_DISABLED
