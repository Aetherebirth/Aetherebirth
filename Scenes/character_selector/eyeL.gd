extends Node2D

@onready var eyeL_sprite = $Sprite2D
@onready var eyeL_color_button = $"../../eyeL/EyeLColorButton"

# keys
var eyeL_keys = []
var current_eyeL_index = 0

func _ready():
	eyeL_color_button.color = Global.eyeL_color
	set_sprite_keys()
	update_sprite()

# set eyeL keys
func set_sprite_keys():
	eyeL_keys = Global.eyeL_collection.keys()

# Update texture and modulate
func update_sprite():
	var current_sprite = eyeL_keys[current_eyeL_index]
	eyeL_sprite.texture = Global.eyeL_collection[current_sprite]
	eyeL_sprite.modulate = Global.eyeL_color
	
	Global.selected_eyeL = current_sprite

func _on_collection_button_pressed():
	current_eyeL_index = (current_eyeL_index + 1) % eyeL_keys.size()
	update_sprite()

func _on_color_button_color_changed(color):
	Global.eyeL_color = eyeL_color_button.color
	update_sprite()
