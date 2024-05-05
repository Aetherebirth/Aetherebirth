extends Node2D

@onready var shirt_sprite = $Sprite2D

# keys
var shirt_keys = []
var color_keys = []
var current_shirt_index = 0
var current_color_index = 0

func _ready():
	set_sprite_keys()
	update_sprite()

# set shirt keys
func set_sprite_keys():
	shirt_keys = Global.shirt_collection.keys()

# Update texture and modulate
func update_sprite():
	var current_sprite = shirt_keys[current_shirt_index]
	shirt_sprite.texture = Global.shirt_collection[current_sprite]
	shirt_sprite.modulate = Global.shirt_color[current_color_index]
	
	Global.selected_shirt = current_sprite
	Global.selected_shirt_color = Global.shirt_color[current_color_index]

func _on_collection_button_pressed():
	current_shirt_index = (current_shirt_index + 1) % shirt_keys.size()
	update_sprite()

func _on_color_button_pressed():
	current_color_index = (current_color_index + 1) % Global.shirt_color.size()
	update_sprite()
