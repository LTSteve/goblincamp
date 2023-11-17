extends Resource

class_name SignalBus

signal on_signal()

#clean up on scene load
func initialize():
	for connection in on_signal.get_connections():
		on_signal.disconnect(connection.callable)
