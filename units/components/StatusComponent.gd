extends Node

class_name StatusComponent

@export var status_component_resource: StatusComponentResource

@export var material_override: MaterialOverrideComponent

func _on_state_changed(state_states: Array[Unit.State]):
	if state_states.has(Unit.State.BURNING):
		material_override.add_color(status_component_resource.burn_color)
		material_override.remove_emission_color(status_component_resource.cold_color)
		material_override.remove_emission_color(status_component_resource.bleed_color)
	elif state_states.has(Unit.State.CHILLED):
		material_override.add_emission_color(status_component_resource.cold_color)
		material_override.remove_color(status_component_resource.burn_color)
		material_override.remove_emission_color(status_component_resource.bleed_color)
	elif state_states.has(Unit.State.BLEEDING):
		material_override.add_emission_color(status_component_resource.bleed_color)
		material_override.remove_emission_color(status_component_resource.cold_color)
		material_override.remove_color(status_component_resource.burn_color)
	else:
		material_override.remove_emission_color(status_component_resource.bleed_color)
		material_override.remove_emission_color(status_component_resource.cold_color)
		material_override.remove_color(status_component_resource.burn_color)
