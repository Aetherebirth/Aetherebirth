extends Node2D

@onready var shirt_sprite = $Sprite2D
@onready var shirt_color_button = $"../../shirt/ShirtColorButton"

# keys
var shirt_keys = []
var current_shirt_index = 0

func _ready():
	shirt_color_button.color = Global.shirt_color
	set_sprite_keys()
	update_sprite()

# set eyeR keys
func set_sprite_keys():
	shirt_keys = Global.shirt_collection.keys()

# Update texture and modulate
func update_sprite():
	var current_sprite = shirt_keys[current_shirt_index]
	shirt_sprite.texture = Global.shirt_collection[current_sprite]
	shirt_sprite.modulate = Global.shirt_color
	
	Global.selected_shirt = current_sprite

func _on_collection_button_pressed():
	current_shirt_index = (current_shirt_index + 1) % shirt_keys.size()
	update_sprite()

func _on_color_button_color_changed(color):
	Global.shirt_color = shirt_color_button.color
	update_sprite()
