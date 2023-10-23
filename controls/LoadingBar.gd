extends Panel

class_name LoadingBar

static var I: LoadingBar

signal on_loaded()

var max_width: float
var finished: bool = false

var _scene_ref: String

func _ready():
	max_width = size.x
	I = self
	set_loading(0)

func _process(_delta):
	if !_scene_ref: return
	
	var complete_percent = []
	ResourceLoader.load_threaded_get_status(_scene_ref,complete_percent)
	set_loading(complete_percent[0])

func set_loading(percent:float):
	size.x = max_width * percent
	if percent >= 1 && !finished:
		on_loaded.emit()
		finished = true

func set_load(scene_ref: String):
	_scene_ref = scene_ref
