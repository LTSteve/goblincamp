extends Node3D

class_name CardDisplay

@export var card_defaults: CardDefaults
@export var card_resource: CardResource

@export var card_title: Label
@export var card_description: Label

@onready var material_override: MaterialOverrideComponent = $"MaterialOverrideComponent"

#have to do this to avoid errors
@onready var ui_material_override: MaterialOverrideComponent = $"MeshInstance3D2/MaterialOverrideComponent"
@onready var ui_viewport: SubViewport = $"SubViewport"

var hidden := true
var no_flip := false

var show_next_rank: bool = false

var _tween: Tween

func _ready():
	if card_resource: initialize(hidden)

func initialize(flipped:=true):
	if ! card_resource: return
	
	if !no_flip:
		hidden = flipped
		rotation_degrees = Vector3(0, 180 if hidden else 0, 0)
	
	material_override.set_color(card_defaults.rarity_colors[card_resource.rarity])
	card_title.text = card_resource.title
	var current_modifier = ModifierManager.get_modifier_by_resource(card_resource)
	var current_rank = current_modifier.current_rank
	var text = card_resource.descriptions[min(card_resource.descriptions.size() - 1, current_rank)]
	card_description.text = ExpressionsParser.parse(text, { "current_rank": current_rank + (1 if show_next_rank else 0)}, current_modifier.params)
	
	call_deferred("_assign_ui_texture")

func flip():
	if no_flip: return
	_set_up_tween()
	if hidden:
		hidden = false
		_tween.tween_property(self, "rotation_degrees", Vector3(0,0,0), 0.2)
	else:
		hidden = true
		_tween.tween_property(self, "rotation_degrees", Vector3(0,180,0), 0.2)

func _set_up_tween():
	if _tween:
		_tween.stop()
		_tween = null
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)

func _assign_ui_texture():
	var ui_material = ui_material_override.get_material()
	ui_material.albedo_texture = ui_viewport.get_texture()
