extends Node

class_name TypeWriter

const chunk_pace: float = 0.18

var to_type: String = ""
var typed: String = ""

var _chunk_progress: float = 0.0
var _progress: float = 0.0

@export var pace_setting: SettingResource

@export var audio_stream_player: AudioStreamPlayer

@export var sfx_resource: SFXResource

func set_text(text:String):
	to_type = text
	typed = ""
	_chunk_progress = 0.0
	_progress = 0.0
	get_parent().text = typed
	set_process(true)

func is_typing() -> bool:
	return to_type != typed

func hurry():
	_progress = to_type.length()
	_chunk_progress = chunk_pace

func _process(delta):
	_chunk_progress += delta
	_progress += delta
	if _chunk_progress < chunk_pace: return
	_chunk_progress -= chunk_pace
	
	if typed == to_type:
		set_process(false)
		return
	
	var character_count := int(_progress * (pace_setting.current_value + 1) * 5 / chunk_pace)
	if character_count == to_type.length():
		typed = to_type
	else:
		var substr = to_type.substr(0,character_count)
		typed = substr
	
	get_parent().text = typed
	if audio_stream_player && sfx_resource:
		audio_stream_player.stop()
		audio_stream_player.stream = sfx_resource.typewriter_sounds.pick_random()
		audio_stream_player.play()
