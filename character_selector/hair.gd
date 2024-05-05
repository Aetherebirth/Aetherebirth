extends Node2D

@onready var hair_sprite = $Sprite2D

# keys
var hair_keys = []
var color_keys = []
var current_hair_index = 0
var current_color_index = 0

func _ready():
	set_sprite_keys()
	update_sprite()

# set hair keys
func set_sprite_keys():
	hair_keys = Global.hair_collection.keys()

# Update texture and modulate
func update_sprite():
	var current_sprite = hair_keys[current_hair_index]
	if current_sprite == "none":
		hair_sprite.texture = null
	else:
		hair_sprite.texture = Global.hair_collection[current_sprite]
		hair_sprite.modulate = Global.hair_color[current_color_index]
	
	Global.selected_hair = current_sprite
	Global.selected_hair_color = Global.hair_color[current_color_index]

func _on_collection_button_pressed():
	current_hair_index = (current_hair_index + 1) % hair_keys.size()
	update_sprite()

func _on_color_button_pressed():
	current_color_index = (current_color_index + 1) % Global.hair_color.size()
	update_sprite()
