@tool

extends Resource

class_name LayeredNoise

@export var noise_scales: Array[float] = []

@export var noise_layers: Array[FastNoiseLite] = []

@export var middle_scale:float = 0.1

func assign_seed(s: int):
	for layer in noise_layers:
		layer.seed = s

func point_in_noise(percent: Vector2) -> float:
	var sum: float = 0
	var scale_sum: float = 0
	
	for i in noise_layers.size():
		var scale = 1.0 if i >= noise_scales.size() else noise_scales[i]
		var layer = noise_layers[i]
		sum += absf(layer.get_noise_2dv(percent * 10)) * scale
		scale_sum += scale
	
	var height = sum / scale_sum
	
	var distance_from_center = (percent - Vector2(0.5,0.5)).length()
	
	if distance_from_center < middle_scale:
		height = lerpf(height, 0, 0.8)
	elif distance_from_center < middle_scale*2:
		height = lerpf(height, 0, 0.5)
	
	return height

func _between(val:float,side1:float,side2:float) -> bool:
	return val > side1 && val < side2
