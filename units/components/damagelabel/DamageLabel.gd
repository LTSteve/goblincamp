extends Label3D

class_name DamageLabel

@export var settings: DamageLabelSettingsResource

var damage: int
var damage_type: Damage.Type
var is_crit: bool
var is_ally: bool

func _ready():
	text = str(damage)
	var crit_multiplier = settings.crit_color_multiplier if is_crit else Color.WHITE
	var damage_color = settings.ally_damage_color if is_ally else settings.damage_base_colors[damage_type]
	modulate = damage_color * crit_multiplier
	pixel_size = settings.pixel_size
	if is_crit: pixel_size *= settings.crit_font_scale
	position = Vector3.RIGHT.rotated(Vector3.UP, randf_range(0,359.99)) * settings.random_spawn_radius
	
	var tween = create_tween()
	tween.set_ease(settings.ease_type)
	tween.tween_property(self, "position", self.position + Vector3(0, settings.movement, 0), settings.label_lifespan)
	tween.finished.connect(queue_free)
