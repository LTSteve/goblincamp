extends Panel

class_name LoadingBar

static var I: LoadingBar

signal on_loaded()

@export var message_label: Label

var max_width: float
var finished: bool = false

var _to_load: LinkedList
var _num_loaded: int = 0

func _ready():
	max_width = size.x
	I = self
	set_loading(0)

func _process(_delta):
	if !_to_load: return
	
	var complete_percent = []
	ResourceLoader.load_threaded_get_status(_to_load.front(),complete_percent)
	
	var prev_completed = _num_loaded / (_to_load.size() as float)
	var current_completion = complete_percent[0] / (_to_load.size() as float)
	set_loading(prev_completed + current_completion)
	
	if complete_percent[0] >= 1.0:
		_to_load.pop()
		_num_loaded += 1

func set_loading(percent:float):
	size.x = max_width * percent
	if percent >= 1 && !finished:
		on_loaded.emit()
		finished = true

func set_load(resource_path: String, message: String = ""):
	if _to_load == null: _to_load = LinkedList.new()
	ResourceLoader.load_threaded_request(resource_path)
	_to_load.push(resource_path)
	if message:
		message_label.text = message
