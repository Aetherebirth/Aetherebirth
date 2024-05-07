extends Node2D

@onready var body_sprite = $Sprite2D
@onready var body_color_button = $"../../Body/BodyColorButton"

# keys
var body_keys = []
var current_body_index = 0

func _ready():
	body_color_button.color = Global.body_color
	set_sprite_keys()
	update_sprite()

# set body keys
func set_sprite_keys():
	body_keys = Global.body_collection.keys()

# Update texture and modulate
func update_sprite():
	var current_sprite = body_keys[current_body_index]
	body_sprite.texture = Global.body_collection[current_sprite]
	body_sprite.modulate = Global.body_color
	
	Global.selected_body = current_sprite

func _on_collection_button_pressed():
	current_body_index = (current_body_index + 1) % body_keys.size()
	update_sprite()

func _on_color_button_color_changed(color):
	Global.body_color = body_color_button.color
	update_sprite()
