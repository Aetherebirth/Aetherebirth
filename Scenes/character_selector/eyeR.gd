extends Node2D

@onready var eyeR_sprite = $Sprite2D

# keys
var eyeR_keys = []
var color_keys = []
var current_eyeR_index = 0
var current_color_index = 0

func _ready():
	set_sprite_keys()
	update_sprite()

# set eyeR keys
func set_sprite_keys():
	eyeR_keys = Global.eyeR_collection.keys()

# Update texture and modulate
func update_sprite():
	var current_sprite = eyeR_keys[current_eyeR_index]
	if current_sprite == "none":
		eyeR_sprite.texture = null
	else:
		eyeR_sprite.texture = Global.eyeR_collection[current_sprite]
		eyeR_sprite.modulate = Global.eyeR_color[current_color_index]
	
	Global.selected_eyeR = current_sprite
	Global.selected_eyeR_color = Global.eyeR_color[current_color_index]

func _on_collection_button_pressed():
	current_eyeR_index = (current_eyeR_index + 1) % eyeR_keys.size()
	update_sprite()

func _on_color_button_pressed():
	current_color_index = (current_color_index + 1) % Global.eyeR_color.size()
	update_sprite()
