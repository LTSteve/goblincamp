extends Node3D

class_name DamageLabel

@export var settings: DamageLabelSettingsResource

@export var label: Label3D

var damage: int
var damage_type: Damage.Type
var is_crit: bool
var is_ally: bool
var audio_stream: AudioStream

var new_target_position:Vector3 = Vector3.ZERO

@onready var audio_stream_player:AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready():
	label.text = str(damage)
	var crit_multiplier = settings.crit_color_multiplier if is_crit else Color.WHITE
	var damage_color = settings.ally_damage_color if (is_ally && damage_type != Damage.Type.Heal) else settings.damage_base_colors[damage_type]
	label.modulate = damage_color * crit_multiplier
	label.pixel_size = settings.pixel_size * 0.01
	if is_crit: label.pixel_size *= settings.crit_font_scale
	
	if audio_stream:
		audio_stream_player.stream = audio_stream
		audio_stream_player.play()
	
	call_deferred("_start_tween")

func _process(delta):
	label.position = lerp(label.position, new_target_position, delta)

func _start_tween():
	global_position = global_position + Vector3.RIGHT.rotated(Vector3.UP, randf_range(0,359.99)) * settings.random_spawn_radius
	var tween = create_tween()
	tween.set_ease(settings.ease_type)
	tween.tween_property(self, "global_position", self.global_position + Vector3(0, settings.movement, 0), settings.label_lifespan)
	tween.finished.connect(queue_free)
