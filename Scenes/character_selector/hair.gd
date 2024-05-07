extends Node2D

@onready var hair_sprite = $Sprite2D
@onready var hair_color_button = $"../../Hair/HairColorButton"

# keys
var hair_keys = []
var current_hair_index = 0

func _ready():
	hair_color_button.color = Global.hair_color
	set_sprite_keys()
	update_sprite()

# set hair keys
func set_sprite_keys():
	hair_keys = Global.hair_collection.keys()

# Update texture and modulate
func update_sprite():
	var current_sprite = hair_keys[current_hair_index]
	hair_sprite.texture = Global.hair_collection[current_sprite]
	hair_sprite.modulate = Global.hair_color
	
	Global.selected_hair = current_sprite

func _on_collection_button_pressed():
	current_hair_index = (current_hair_index + 1) % hair_keys.size()
	update_sprite()

func _on_color_button_color_changed(color):
	Global.hair_color = hair_color_button.color
	update_sprite()
