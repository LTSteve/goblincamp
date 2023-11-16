class_name RatioMap

var _data:Dictionary = {}

var _total_size: float = 0.0

func _init(dic:Dictionary):
	_data = dic
	for key in dic.keys():
		_total_size += dic[key]

func _append(key, value:float):
	_data[key] = value
	_total_size += value

func _get_random():
	var r = randf_range(0,_total_size)
	
	for key in _data.keys():
		var value = _data[key]
		r -= value
		if r <= 0:
			return key
	
	return _data[_data.keys().back()]
