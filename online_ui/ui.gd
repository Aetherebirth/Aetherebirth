extends Control

signal start_server
signal connect_client(ip)

@export var hide_ui_and_connect: bool


func _ready():
	if Connection.is_server(): return
	
	if hide_ui_and_connect:
		connect_client_emit()
	else:
		show_ui()


func start_server_emit() -> void:
	start_server.emit()
	$MainMenu.visible = false


func connect_client_emit() -> void:
	var ip = $MainMenu/Connection/IpInput.text
	if(validate_ip(ip)):
		connect_client.emit(ip)
		hide_ui()
	else:
		print("%s is not a valid ip !" % ip)

func validate_ip(ip: String):
	return ip.is_valid_ip_address()

func hide_ui() -> void:
	$MainMenu.visible = false
	$InGameUI.visible = true


func show_ui() -> void:
	$MainMenu.visible = true
	$InGameUI.visible = false
