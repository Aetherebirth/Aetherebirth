extends Control

@onready var username_input = $LoginInputs/Username
@onready var password_input = $LoginInputs/Password
@onready var login_button = $LoginInputs/Login

@onready var create_username_input = $RegisterInputs/Username
@onready var create_password_input = $RegisterInputs/Password
@onready var create_password_confirm_input = $RegisterInputs/PasswordConfirm

func _ready():
	$LoginInputs.show()
	$RegisterInputs.hide()
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
		Gateway.connectToServer(self, username, pasword, false)
		#$LoginTimeout.start()

func _on_login_timeout():
	login_button.disabled = false


func _on_register_pressed():
	if(create_username_input.text == ""):
		print("Please provide a valid username")
	elif(create_password_input.text == ""):
		print("Please provide a valid password")
	elif(create_password_confirm_input.text == ""):
		print("Please repeat your password")
	elif create_password_input.text != create_password_confirm_input.text:
		print("Passwords don't match")
	elif create_password_input.text.length() <= 6:
		print("Password must contain at least 7 characters")
	else:
		$RegisterInputs/Register.disabled = true
		$RegisterInputs/Back.disabled = true
		Gateway.connectToServer(self, create_username_input.text, create_password_input.text, true)



func _on_skip_pressed():
	get_tree().change_scene_to_file("res://Scenes/character_selector/character_creator.tscn")

func _on_switch_to_register_pressed():
	$LoginInputs.hide()
	$RegisterInputs.show()

func _on_switch_to_login_pressed():
	$LoginInputs.show()
	$RegisterInputs.hide()

