extends Control

signal start_server
signal connect_client(ip)

@export var hide_ui_and_connect: bool


func _ready():
	if hide_ui_and_connect:
		connect_client_emit()
	else:
		show_ui()


func connect_client_emit() -> void:
	var ip = $MainMenu/Connection/IpInput.text
	var port = $MainMenu/Connection/PortInput.text
	if(validate_ip(ip) && validate_port(port)):
		connect_client.emit(ip, int(port))
		hide_ui()
	else:
		print("%s:%d is not a valid ip !" % ip % port)

func validate_ip(ip: String):
	return ip.is_valid_ip_address()
	
func validate_port(port: String):
	return (1024 <= int(port) && int(port) <= 49151)

func hide_ui() -> void:
	$MainMenu.visible = false
	$InGameUI.visible = true


func show_ui() -> void:
	$MainMenu.visible = true
	$InGameUI.visible = false
