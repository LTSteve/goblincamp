class_name Wait

static func timer(time:float, node: Node, callback:Callable):
	var t = Timer.new()
	t.timeout.connect(func(): 
		if !is_instance_valid(node): return
		t.queue_free()
		callback.call()
	)
	t.set_wait_time(time)
	t.autostart = true
	node.add_child(t)
