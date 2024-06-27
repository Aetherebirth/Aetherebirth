extends Node

signal connected
signal disconnected

static var is_peer_connected: bool

@export var default_port: int = 6942
@export var max_clients: int
@export var default_ip: String = "127.0.0.1"
@export var use_localhost_in_editor: bool

@export var loginscreen: LoginScreen

var smapi: SceneMultiplayer = SceneMultiplayer.new()

var cert: X509Certificate = load("res://assets/certificate/Aetherebirth_server.crt")
var dtls_options: TLSOptions = TLSOptions.client(cert)

var username: String
var password: String
var register: bool

var server_ip: String

func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	if not smapi.has_multiplayer_peer():
		return
	smapi.poll()

func connectToServer(screen: LoginScreen, _username: String, _password: String, _register: bool, _address:String=default_ip, server_ip_override:String="127.0.0.1") -> void:
	loginscreen = screen
	smapi = SceneMultiplayer.new()
	var gateway_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	register = _register
	
	server_ip = server_ip_override
	var address: String = _address
	
	var err : Error = gateway_peer.create_client(address, default_port)
	#gateway_peer.host.dtls_client_setup("aetherebirth_server.aetherebirth.fr", dtls_options)
	if err != OK:
		print("Cannot connect to gateway. Err: " + str(err))
		disconnected.emit()
		return
	else: print("Connecting to gateway...")
	
	username = _username
	password = _password
	
	smapi.root_path = self.get_path()
	smapi.multiplayer_peer = gateway_peer
	get_tree().set_multiplayer(smapi, smapi.root_path)
	smapi.connected_to_server.connect(_on_connection_succeed)
	smapi.server_disconnected.connect(_on_connection_disconnect)
	smapi.connection_failed.connect(_on_connection_fail)

func _on_connection_fail() -> void:
	print("Failed to connect to login server")
	print("\"Server offline\" pop-up")
	disconnected.emit()
	
func _on_connection_succeed() -> void:
	print("Connected to gateway")
	if(register):
		RegisterRequest()
	else:
		LoginRequest()
	
func _on_connection_disconnect() -> void:
	print("Disconnected from login server")
	disconnected.emit()

@rpc("any_peer", "reliable")
func LoginRequest() -> void:
	print("Requesting login from gateway")
	LoginRequest.rpc_id(1, username, password)
	username = ""
	password = ""

@rpc("any_peer", "reliable")
func RegisterRequest() -> void:
	print("Requesting register from gateway")
	RegisterRequest.rpc_id(1, username, password)
	username = ""
	password = ""

@rpc("authority", "call_remote", "reliable")
func ReturnLoginRequest(results: bool, token: String) -> void:
	print("Login results received")
	smapi.connected_to_server.disconnect(_on_connection_succeed)
	smapi.server_disconnected.disconnect(_on_connection_disconnect)
	smapi.connection_failed.disconnect(_on_connection_fail)
	if results == true:
		print("Connecting to server...")
		GameServer.token = token
		GameServer.ConnectToServer(server_ip)
	else:
		print("Please provide correct username and password")
	disconnected.emit()

@rpc("authority", "call_remote", "reliable")
func ReturnRegisterRequest(message: int) -> void:
	print("Register results received")
	smapi.disconnect_peer(1)
	smapi.connected_to_server.disconnect(_on_connection_succeed)
	smapi.server_disconnected.disconnect(_on_connection_disconnect)
	smapi.connection_failed.disconnect(_on_connection_fail)
	if(message == 1):
		print("Failed to create account")
	elif(message==2):
		print("Username already exists")
	elif(message==3):
		print("Welcome !") 
		loginscreen.register_inputs.hide()
		loginscreen.login_inputs.show()
	loginscreen.back_button.disabled = false
	loginscreen.register_button.disabled = false


func peer_connected(id: int) -> void:
	print("Peer connected to gateway: " + str(id))
func peer_disconnected(id: int) -> void:
	print("Peer disconnected from gateway: " + str(id))
