extends Weapon

class_name MeleeWeapon

@export var collision_areas: Array[Area3D]
@export var hit_spot: Node3D

@export var leave_behind_sfx_scene: PackedScene = preload("res://sfx/leave_behind_sfx.tscn")
@export var hit_sfx: Array[AudioStream]

@export var multi_target: bool = false

var _already_hit:Array[Unit] = []

func _ready():
	super._ready()
	for area in collision_areas:
		area.body_entered.connect(_on_area_3d_body_entered)

func _on_request_attack(target:Unit, me:Unit):
	if ! _try_to_attack(target, me): return
	
	#reset already hit tracker
	_clear_already_hit()
	
	#assign collision mask of hitboxes
	for area in collision_areas:
		area.collision_mask = target.collision_layer

func _clear_already_hit():
	_already_hit = []

# weapon hit enemy
func _on_area_3d_body_entered(enemy):
	if !(enemy is Unit): return
	#track already hit
	if multi_target:
		if _already_hit.has(enemy): return
		_already_hit.append(enemy);
	else:
		if !_already_hit.is_empty(): return
		_already_hit.append(enemy);
	
	var sfx = leave_behind_sfx_scene.instantiate() as LeaveBehindSFX
	sfx.stream = hit_sfx.pick_random()
	get_tree().root.add_child(sfx)
	
	var hit_data = create_hit.execute([enemy, Weapon.HitCreationData.new(hit_spot.global_position)])
	enemy.take_hit(hit_data)
	on_hit_landed.emit(hit_data)
