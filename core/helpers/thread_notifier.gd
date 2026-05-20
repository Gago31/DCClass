class_name ThreadNotifier
extends Node

## Node for running long processes in a thread and notifying
## when they finish running.


## Emits the result of the thread's funciton
## when the thread is no longer alive.
signal thread_finished(result: Variant)


var _thread: Thread
var _auto_delete: bool
var _output = []


func _init(delete_on_finish := true) -> void:
	_auto_delete = delete_on_finish

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	_thread = Thread.new()

func _process(_delta: float) -> void:
	if not _thread.is_alive():
		print("Thread finished")
		var res = _thread.wait_to_finish()
		prints("Output:", _output)
		prints("Response:", res)
		thread_finished.emit(res)
		if _auto_delete:
			queue_free()
		else:
			process_mode = Node.PROCESS_MODE_DISABLED

## Runs the given [code]callable[/code] in a separate thread and emits 
## [signal thread_finished] once it finishes.[br]
##
## Any arguments must be passed to the [code]callable[/code] through 
## [method Callable.bind], like you would for [method Thread.start].
func run_thread(callable: Callable) -> Error:
	print("Thread started...")
	var err := _thread.start(callable)
	if err == OK:
		process_mode = Node.PROCESS_MODE_ALWAYS
	return err
