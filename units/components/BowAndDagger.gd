extends Node3D

class_name BowAndDagger

@export var bow: RangedWeapon
@export var daggers: Array[MeleeWeapon]

@export var mutant: bool = false

var _melee: bool = false
var _in_combat: bool = false

func _on_enter_combat():
	_in_combat = true
	
	if mutant:
		for dagger in daggers:
			dagger._on_enter_combat()
		bow._on_enter_combat()
	elif _melee:
		for dagger in daggers:
			dagger._on_enter_combat()
		bow._on_exit_combat()
	else:
		bow._on_enter_combat()
		for dagger in daggers:
			dagger._on_exit_combat()

func _on_exit_combat():
	_in_combat = false
	for dagger in daggers:
		dagger._on_exit_combat()
	bow._on_exit_combat()

func _on_request_attack(target:Unit, me:Unit):
	if mutant:
		for dagger in daggers:
			dagger._on_request_attack(target, me)
		bow._on_request_attack(target, me)
	elif _melee:
		for dagger in daggers:
			dagger._on_request_attack(target, me)
	else:
		bow._on_request_attack(target, me)

func _on_switch_melee(melee: bool):
	if mutant: return
	if _melee == melee: return
	_melee = melee
	if _in_combat:
		_on_enter_combat()
	else:
		_on_exit_combat()
