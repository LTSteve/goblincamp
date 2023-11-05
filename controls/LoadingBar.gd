extends Panel

class_name LoadingBar

static var I: LoadingBar

signal on_loaded(loaded:Array[Resource])

@export var message_label: Label

var max_width: float
var finished: bool = false

var _to_load: LinkedList
var _num_loaded: int = 0
var _to_load_size: int = 0

var loaded:Array[Resource] = []

func _ready():
	max_width = size.x
	I = self
	set_loading(0)

func _process(_delta):
	if !_to_load || _to_load.size() == 0: return
	
	var complete_percent = []
	
	if OS.has_feature("web"):
		complete_percent = [1.0]
	else:
		ResourceLoader.load_threaded_get_status(_to_load.front(),complete_percent)
	
	var to_load_size = _to_load_size as float
	
	if complete_percent[0] >= 1.0:
		var res_path = _to_load.pop()
		if !OS.has_feature("web"):
			loaded.append(ResourceLoader.load_threaded_get(res_path))
		_num_loaded += 1
		set_loading(_num_loaded / to_load_size)
	else:
		set_loading((_num_loaded + complete_percent[0]) / to_load_size)

func set_loading(percent:float):
	size.x = max_width * percent
	if percent >= 1 && !finished:
		on_loaded.emit(loaded)
		finished = true

func set_load(resource_path: String, message: String = ""):
	if _to_load == null: _to_load = LinkedList.new()
	
	if OS.has_feature("web"):
		#web can't be trusted with threads
		loaded.append(load(resource_path))
	else:
		ResourceLoader.load_threaded_request(resource_path)
	_to_load.push(resource_path)
	_to_load_size += 1
	if message:
		message_label.text = message
