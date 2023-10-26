extends Node

class_name BrainComponent

@export var unit:Unit
@export var weapon_holder: Node3D
@export var flee_range: Area3D
@export var flee_dist2: float = 64

var target:Unit
var weapons:Array[Weapon]
var fleeing:Array[Unit] = []
var nearby_allies: Array[Unit] = []

@export var behaviours: Array[Behaviour]

var behaviour_datas = []

var override_behaviours: Array[Behaviour] = []

var override_behaviour_datas = []

signal request_attack(target:Unit,me:Unit)
signal enter_combat()
signal exit_combat()
signal on_lock_target(target:Unit)
signal switch_melee(melee:bool)

func _ready():
	if flee_range:
		flee_range.area_entered.connect(_on_body_entered_flee_range)
	
	for behaviour in behaviours:
		behaviour_datas.append(behaviour.initialize(self))

func add_override_behaviour(override:Behaviour):
	override_behaviours.push_front(override)
	override_behaviour_datas.push_front(override.initialize(self))

func remove_override_behaviour(override:Behaviour):
	var index = override_behaviours.find(override)
	if index != -1:
		override_behaviours.remove_at(index)
		override_behaviour_datas.remove_at(index)

func _process(delta):
	
	_clean_fleeing_list()
	
	#process override behaviours first if any
	for i in override_behaviours.size():
		override_behaviours[i].assign_target(delta, self, override_behaviour_datas[i])
		if override_behaviours[i].process(delta, self, override_behaviour_datas[i]):
			return
	for i in behaviours.size():
		behaviours[i].assign_target(delta, self, behaviour_datas[i])
		if behaviours[i].process(delta, self, behaviour_datas[i]):
			return

func _on_die():
	for i in override_behaviours.size():
		override_behaviours[i].clean_up(self, override_behaviour_datas[i])
	for i in behaviours.size():
		behaviours[i].clean_up(self, behaviour_datas[i])

func _clean_fleeing_list():
	var to_remove = []
	var index = 0
	for enemy in fleeing:
		if !enemy || !is_instance_valid(enemy) || enemy.global_position.distance_squared_to(unit.global_position) > flee_dist2:
			to_remove.append(index)
		index += 1
	to_remove.reverse()
	for i in to_remove.size():
		fleeing.remove_at(to_remove[i])
	
	to_remove = []
	index = 0
	for player in nearby_allies:
		if !player || !is_instance_valid(player) || player.global_position.distance_squared_to(unit.global_position) > flee_dist2:
			to_remove.append(index)
		index += 1
	to_remove.reverse()
	for i in to_remove.size():
		nearby_allies.remove_at(to_remove[i])

func _on_body_entered_flee_range(entered_unit):
	if !(entered_unit is Unit) || entered_unit == unit: return
	if entered_unit.is_enemy != unit.is_enemy:
		fleeing.append(entered_unit)
	else:
		nearby_allies.append(entered_unit)
