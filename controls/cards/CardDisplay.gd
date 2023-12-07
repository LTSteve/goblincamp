extends Node3D

class_name CardDisplay

@export var card_defaults: CardDefaults
@export var card_resource: CardResource

@export var card_title: Label
@export var card_description: Label

@onready var material_override: MaterialOverrideComponent = $"card_facer/MaterialOverrideComponent"

#have to do this to avoid errors
@onready var ui_material_override: MaterialOverrideComponent = $"card_facer/MeshInstance3D2/MaterialOverrideComponent"
@onready var ui_viewport: SubViewport = $"card_facer/SubViewport"

@onready var texture_rect_3d: TextureRect3D = $"card_facer/SubViewport/Theme/VBoxContainer/MarginContainer2/3DTextureRect"

@onready var card_model: Node3D = $"card_facer"

var hidden := true
var no_flip := false

var show_next_rank: bool = false

var _flip_tween: Tweenifier
var _look_at_tween: Tweenifier

var _main_cam: Camera3D

func _ready():
	_flip_tween = Tweenifier.new(self, "rotation_degrees", 0.2)
	_look_at_tween = Tweenifier.new(card_model, "rotation", 0.1)
	if card_resource: initialize(hidden)
	_main_cam = CameraRig.I.camera

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
	
	if card_resource.icon_model:
		texture_rect_3d.model_scene = card_resource.icon_model
		texture_rect_3d.initialize()
	
	call_deferred("_assign_ui_texture")

func flip():
	if no_flip: return
	if hidden:
		hidden = false
		_flip_tween.tween(Vector3(0,0,0))
	else:
		hidden = true
		_flip_tween.tween(Vector3(0,180,0))

func _assign_ui_texture():
	var ui_material = ui_material_override.get_material()
	ui_material.albedo_texture = ui_viewport.get_texture()

func _mouse_hover_exited():
	_tween_to_direction(card_model.global_transform.basis.x)

func _mouse_input_event(_camera, event, _position, normal, _shape_idx):
	if event is InputEventMouseMotion:
		_tween_to_direction(normal)

func _tween_to_direction(dir: Vector3):
	var forward = card_model.global_transform.basis.x
	var rot_q: Quaternion
	
	if forward == dir:
		rot_q = Quaternion.IDENTITY
	else:
		var a = forward.cross(dir)
		rot_q = Quaternion(a.x,a.y,a.z, 1 + forward.dot(dir))
		rot_q = rot_q.normalized()
	
	var rot_e := rot_q.get_euler()
	
	print("look at")
	print(forward)
	print(rot_e)
	
	_look_at_tween.tween(rot_e)
