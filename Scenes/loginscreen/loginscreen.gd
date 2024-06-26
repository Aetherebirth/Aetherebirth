extends Control
class_name LoginScreen

@onready var username_input: LineEdit = $LoginInputs/Username
@onready var password_input: LineEdit = $LoginInputs/Password
@onready var login_button: Button = $LoginInputs/Login

@onready var create_username_input: LineEdit = $RegisterInputs/Username
@onready var create_password_input: LineEdit = $RegisterInputs/Password
@onready var create_password_confirm_input: LineEdit = $RegisterInputs/PasswordConfirm
@onready var register_button: Button = $RegisterInputs/Register
@onready var back_button: Button = $RegisterInputs/Back

@onready var login_inputs: VBoxContainer = $LoginInputs
@onready var register_inputs: VBoxContainer = $RegisterInputs


@onready var server_address: LineEdit = $ServerAddress
@onready var gateway_address: LineEdit = $GatewayAddress

var config: ConfigFile = ConfigFile.new()

func _ready() -> void:
	config.load("user://network.cfg")
	server_address.text = config.get_value("network", "last_server_address", "127.0.0.1")
	gateway_address.text = config.get_value("network", "last_gateway_address", "127.0.0.1")
	login_inputs.show()
	register_inputs.hide()
	Gateway.disconnected.connect(func()->void:login_button.disabled = false)

func _on_login_pressed() -> void:
	if(username_input.text == "" || password_input.text == ""):
		# Popup
		print("Please provide a valid username and password !")
	else:
		config.set_value("network", "last_server_address", server_address.text)
		config.set_value("network", "last_gateway_address", gateway_address.text)
		config.save("user://network.cfg")
		login_button.disabled = true
		var username: String = username_input.text
		var password: String = password_input.text
		print("Attempt to login")
		Gateway.connectToServer(self, username, password.sha256_text(), false, gateway_address.text, server_address.text)
		#$LoginTimeout.start()

func _on_login_timeout() -> void:
	login_button.disabled = false


func _on_register_pressed() -> void:
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
		config.set_value("network", "last_server_address", server_address.text)
		config.set_value("network", "last_gateway_address", gateway_address.text)
		config.save("user://network.cfg")
		register_button.disabled = true
		back_button.disabled = true
		Gateway.connectToServer(self, create_username_input.text, create_password_input.text.sha256_text(), true, gateway_address.text, server_address.text)



func _on_skip_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/character_selector/character_creator.tscn")

func _on_switch_to_register_pressed() -> void:
	login_inputs.hide()
	register_inputs.show()

func _on_switch_to_login_pressed() -> void:
	login_inputs.show()
	register_inputs.hide()

