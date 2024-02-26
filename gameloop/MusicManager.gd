extends Node

class_name MusicManager

static var MM: MusicManager = null

const VOLUME_OFF: float = -80.0
const FADE_TIME: float = 0.5

@onready var background_music: AudioStreamPlayer = $"BackgroundMusic"
@onready var background_music_combat: AudioStreamPlayer = $"BackgroundMusicCombat"

@export var music_volume_setting: SettingResource

@export_group("Observables")
@export var is_day_resource: ObservableResource

var _fade_progress: float = 0.0
var _in_combat_ness: float = 0.0

func _ready():
	if MM == null:
		MM = self
		set_meta("do_not_destroy_on_load", true)
		call_deferred("_do_reparent_root")
		_fade_in()
		is_day_resource.value_changed.connect(_on_day_changed)
	else:
		queue_free()

func _do_reparent_root():
	reparent(get_tree().root)

func _fade_in():
	background_music_combat.volume_db = VOLUME_OFF
	background_music.volume_db = VOLUME_OFF
	
	var fade_in_tween = get_tree().create_tween()
	fade_in_tween.tween_property(self, "_fade_progress", 1.0, FADE_TIME).set_trans(Tween.TRANS_SINE)

func _set_in_combat(in_combat: bool):
	var in_combat_tween = get_tree().create_tween()
	in_combat_tween.tween_property(self, "_in_combat_ness", 1.0 if in_combat else 0.0, FADE_TIME)

func _on_day_changed(is_d,_o):
	_set_in_combat(!is_d)

func _process(_delta):
	var volume_full = _volume_setting_to_db(music_volume_setting.current_value)
	if _fade_progress < 1.0:
		background_music_combat.volume_db = VOLUME_OFF
		background_music.volume_db = lerpf(VOLUME_OFF, volume_full, _fade_progress)
	else:
		background_music_combat.volume_db = lerpf(VOLUME_OFF, volume_full, _in_combat_ness)
		background_music.volume_db = lerpf(VOLUME_OFF, volume_full, 1.0 - _in_combat_ness)

func _volume_setting_to_db(setting:float):
	return setting * (-VOLUME_OFF) + VOLUME_OFF
