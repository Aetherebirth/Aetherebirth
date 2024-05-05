extends Node2D

@onready var name_box = $CreatorScreen/Menu/Details/TextEdit
var player_name = ""

func _ready():
	if("--server" in OS.get_cmdline_args()):
		get_tree().change_scene_to_file("res://Scenes/main/game.tscn")

# Player name
func _on_text_edit_text_changed():
	player_name = name_box.text

# Change scene
func _on_confirm_button_pressed():
	Global.player_name = player_name
	get_tree().change_scene_to_file("res://Scenes/main/game.tscn")
