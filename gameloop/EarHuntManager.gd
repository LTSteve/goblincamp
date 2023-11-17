extends Node

class_name EarHuntManager

@export_group("Observables")
@export var on_day_resource: ObservableResource
@export var ears_resource: ObservableResource
@export var players_resource: ObservableResource

func _ready():
	on_day_resource.value_changed.connect(_on_day_changed)

func _on_day_changed(is_d,_o):
	if !is_d: return
	call_deferred("_assign_all_ears_to_ear_hunters")

func _assign_all_ears_to_ear_hunters():
	for ear in ears_resource.value:
		var unit := Global.nearest_unit(players_resource.value, ear.global_position) as Unit
		var brain := unit.find_child("BrainComponent") as BrainComponent
		var ear_hunt_behaviour_ctx := brain.get_ctx("EarHuntBehaviour") as EarHuntBehaviour.EarHuntContext
		ear_hunt_behaviour_ctx.targeted_ears.append(ear)
