extends TextureRect

class_name TextureRect3D

@onready var sub_viewport: SubViewport = $"SubViewport"
@onready var cam: Camera3D = $"SubViewport/3DTextureCam"
@onready var model_holder: Node3D = $"SubViewport/3DTextureCam/Model"

@export var model_rotation: Vector3
@export var model_scale: Vector3
@export var model_offset: Vector3

@export var viewport_pixels: Vector2i = Vector2i(512,512)
@export var projection: Camera3D.ProjectionType =  Camera3D.ProjectionType.PROJECTION_ORTHOGONAL

@export var model_scene: PackedScene

var model: Node3D

var cam_surface_normal_observable: ObservableResource

const model_layer:int = 2

func _ready():
	for child in model_holder.get_children():
		if Engine.is_editor_hint():
			child.free()
		else:
			child.queue_free()
	
	cam.projection = projection
	
	sub_viewport.size = viewport_pixels
	
	model = model_scene.instantiate() as Node3D
	
	model.position = model_offset
	model.scale = model_scale
	model.rotation_degrees = model_rotation
	
	model_holder.add_child(model)
	
	for mesh_instance in model.find_children("", "MeshInstance3D"):
		mesh_instance.set_layer_mask_value(model_layer, true)
