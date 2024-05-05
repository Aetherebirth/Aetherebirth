extends Node2D

@onready var eyeL_sprite = $Sprite2D

# keys
var eyeL_keys = []
var color_keys = []
var current_eyeL_index = 0
var current_color_index = 0

func _ready():
	set_sprite_keys()
	update_sprite()

# set eyeL keys
func set_sprite_keys():
	eyeL_keys = Global.eyeL_collection.keys()

# Update texture and modulate
func update_sprite():
	var current_sprite = eyeL_keys[current_eyeL_index]
	if current_sprite == "none":
		eyeL_sprite.texture = null
	else:
		eyeL_sprite.texture = Global.eyeL_collection[current_sprite]
		eyeL_sprite.modulate = Global.eyeL_color[current_color_index]
	
	Global.selected_eyeL = current_sprite
	Global.selected_eyeL_color = Global.eyeL_color[current_color_index]

func _on_collection_button_pressed():
	current_eyeL_index = (current_eyeL_index + 1) % eyeL_keys.size()
	update_sprite()

func _on_color_button_pressed():
	current_color_index = (current_color_index + 1) % Global.eyeL_color.size()
	update_sprite()
