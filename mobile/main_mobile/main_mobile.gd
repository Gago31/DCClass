extends Control

@onready var core_signals: CoreEventBus = Engine.get_singleton(&"CoreSignals")
@onready var mobile_signals: MobileEventBus = Engine.get_singleton(&"MobileSignals")

@onready var resources_class: ResourcesClassMobile = %Resources

@onready var UI: ClassUIMobile = %UI

func _enter_tree() -> void:
	Engine.register_singleton(&"CoreSignals", CoreEventBus.new())
	Engine.register_singleton(&"MobileSignals", MobileEventBus.new())


func _ready() -> void:
	#PersistenceMobile.core_signals = core_signals
	#PersistenceMobile.mobile_signals = mobile_signals
	#PersistenceMobile.resources_class = resources_class
	#PersistenceMobile._setup()
	UI._setup()
