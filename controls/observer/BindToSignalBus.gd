extends Node

class_name BindToSignalBus

@export var this: Button

@export_category("Signal Buses")
@export var signal_bus_resource: SignalBus

func _ready():
	this.pressed.connect(_on_pressed)

func _on_pressed():
	signal_bus_resource.on_signal.emit()
