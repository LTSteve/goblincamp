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

signal request_attack(target:Unit,me:Unit)
signal enter_combat()
signal exit_combat()
signal on_lock_target(target:Unit)
signal switch_melee(melee:bool)

func _ready():
	for behaviour in behaviours:
		behaviour_datas.append(behaviour.initialize(self))

func _process(delta):
	for i in behaviours.size():
		behaviours[i].assign_target(delta, self, behaviour_datas[i])
		if behaviours[i].process(delta, self, behaviour_datas[i]):
			break
	

