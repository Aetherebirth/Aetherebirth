extends Node2D

@onready var eyeR_sprite = $Sprite2D
@onready var eyeR_color_button = $"../../eyeR/EyeRColorButton"

# keys
var eyeR_keys = []
var current_eyeR_index = 0

func _ready():
	eyeR_color_button.color = Global.eyeR_color
	set_sprite_keys()
	update_sprite()

# set eyeR keys
func set_sprite_keys():
	eyeR_keys = Global.eyeR_collection.keys()

# Update texture and modulate
func update_sprite():
	var current_sprite = eyeR_keys[current_eyeR_index]
	eyeR_sprite.texture = Global.eyeR_collection[current_sprite]
	eyeR_sprite.modulate = Global.eyeR_color
	
	Global.selected_eyeR = current_sprite

func _on_collection_button_pressed():
	current_eyeR_index = (current_eyeR_index + 1) % eyeR_keys.size()
	update_sprite()

func _on_color_button_color_changed(color):
	Global.eyeR_color = eyeR_color_button.color
	update_sprite()
