extends Panel

class_name RitualDisplay

@onready var ritual_name: Label = $"VBoxContainer/MarginContainer2/Label"
@onready var price_button: Button = $"VBoxContainer/MarginContainer/Button"
@onready var resource_cost_container: Container = $"VBoxContainer/MarginContainer/Button/HBoxContainer"

var ritual:Ritual

func _ready():
	var resource_cost_scene = DB.I.scenes.resource_cost_scene
	
	if !ritual.available:
		disable()
		return
	
	for child in resource_cost_container.get_children():
		child.queue_free()
	
	for i in ritual.resources.size():
		var resource_texture = ritual.resource_textures[i]
		var price = ritual.prices[i]
		var new_resource_cost = resource_cost_scene.instantiate() as ResourceCost
		resource_cost_container.add_child(new_resource_cost)
		new_resource_cost.cost_label.text = str(price)
		new_resource_cost.resource_image.texture = resource_texture
	
	var bredth = "Broad " if ritual.size == Ritual.Size.Broad else ("Narrow " if ritual.size == Ritual.Size.Narrow else "")
	var type = "Basic " if ritual.type == Ritual.Type.Basic else ("Epic " if ritual.type == Ritual.Type.Epic else "Advanced ")
	
	ritual_name.text = "%s%sRitual" %[bredth, type]

func disable():
	price_button.disabled = true
	for child in resource_cost_container.get_children():
		child.queue_free()
	price_button.text = "PURCHASED"
