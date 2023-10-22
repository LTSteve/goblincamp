extends Node

class_name BrainComponent

@export var unit:Unit
@export var weapon_holder: Node3D
@export var flee_range: Area3D

var target:Unit
var weapons:Array[Weapon]
var fleeing:Array[Unit] = []

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
