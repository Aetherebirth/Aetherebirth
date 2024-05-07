extends Node2D

@onready var pants_sprite = $Sprite2D
@onready var pants_color_button = $"../../pants/PantsColorButton"

# keys
var pants_keys = []
var current_pants_index = 0

func _ready():
	pants_color_button.color = Global.pants_color
	set_sprite_keys()
	update_sprite()

# set pants keys
func set_sprite_keys():
	pants_keys = Global.pants_collection.keys()

# Update texture and modulate
func update_sprite():
	var current_sprite = pants_keys[current_pants_index]
	pants_sprite.texture = Global.pants_collection[current_sprite]
	pants_sprite.modulate = Global.pants_color
	
	Global.selected_pants = current_sprite

func _on_collection_button_pressed():
	current_pants_index = (current_pants_index + 1) % pants_keys.size()
	update_sprite()

func _on_color_button_color_changed(color):
	Global.pants_color = pants_color_button.color
	update_sprite()
