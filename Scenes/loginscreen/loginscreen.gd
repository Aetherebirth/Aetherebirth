extends Control

@onready var username_input = $LoginInputs/Username
@onready var password_input = $LoginInputs/Password
@onready var login_button = $LoginInputs/Login

func _ready():
	Gateway.disconnected.connect(func():login_button.disabled = false)

func _on_login_pressed():
	if(username_input.text == "" || password_input.text == ""):
		# Popup
		print("Please provide a valid username and password !")
	else:
		login_button.disabled = true
		var username = username_input.text
		var pasword = password_input.text
		print("Attempt to login")
		Gateway.connectToServer(self, username, pasword)
		#$LoginTimeout.start()

func _on_login_timeout():
	login_button.disabled = false


func _on_skip_pressed():
	get_tree().change_scene_to_file("res://Scenes/character_selector/character_creator.tscn")

