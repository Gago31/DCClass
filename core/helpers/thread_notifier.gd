class_name ThreadNotifier
extends Node

## Node for running long processes in a thread and notifying
## when they finnish running.


## Emmits the result of the thread's funciton
## when the thread is no longer alive.
signal thread_finished(result: Variant)

var thread: Thread
var auto_delete: bool
var _output = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	thread = Thread.new()

func _init(delete_on_finish := true) -> void:
	auto_delete = delete_on_finish

func _process(_delta: float) -> void:
	if not thread.is_alive():
		print("Thread finished")
		var res = thread.wait_to_finish()
		prints("Output:", _output)
		prints("Response:", res)
		thread_finished.emit(res)
		if auto_delete:
			queue_free()
		else:
			process_mode = Node.PROCESS_MODE_DISABLED

func run_thread(callable: Callable) -> Error:
	print("Thread started...")
	var err := thread.start(callable)
	if err == OK:
		process_mode = Node.PROCESS_MODE_ALWAYS
	return err
