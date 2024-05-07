extends Node2D

@onready var shoes_sprite = $Sprite2D
@onready var shoes_color_button = $"../../shoes/ShoesColorButton"

# keys
var shoes_keys = []
var current_shoes_index = 0

func _ready():
	shoes_color_button.color = Global.shoes_color
	set_sprite_keys()
	update_sprite()

# set shoes keys
func set_sprite_keys():
	shoes_keys = Global.shoes_collection.keys()

# Update texture and modulate
func update_sprite():
	var current_sprite = shoes_keys[current_shoes_index]
	shoes_sprite.texture = Global.shoes_collection[current_sprite]
	shoes_sprite.modulate = Global.shoes_color
	
	Global.selected_shoes = current_sprite

func _on_collection_button_pressed():
	current_shoes_index = (current_shoes_index + 1) % shoes_keys.size()
	update_sprite()

func _on_color_button_color_changed(color):
	Global.shoes_color = shoes_color_button.color
	update_sprite()
