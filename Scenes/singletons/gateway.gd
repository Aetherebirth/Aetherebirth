extends Node

signal connected
signal disconnected

static var is_peer_connected: bool

@export var default_port: int = 6942
@export var max_clients: int
@export var default_ip: String = "127.0.0.1"
@export var use_localhost_in_editor: bool

@export var loginscreen: Control

var smapi: = SceneMultiplayer.new()

var username
var password

func _ready() -> void:
	pass
	
func _process(_delta):
	if not smapi.has_multiplayer_peer():
		return
	smapi.poll()
	
func connectToServer(screen, _username, _password):
	loginscreen = screen
	smapi = SceneMultiplayer.new()
	var gateway_peer = ENetMultiplayerPeer.new()
	
	var address = default_ip
	if OS.has_feature("editor") and use_localhost_in_editor:
		address = "127.0.0.1"
	
	var err = gateway_peer.create_client(address, default_port)
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

func _on_connection_fail():
	print("Failed to connect to login server")
	print("\"Server offline\" pop-up")
	disconnected.emit()
	
func _on_connection_succeed() -> void:
	print("Connected to gateway")
	LoginRequest()
	
func _on_connection_disconnect():
	print("Disconnected from login server")
	disconnected.emit()

@rpc("any_peer", "reliable")
func LoginRequest():
	print("Requesting login from gateway")
	LoginRequest.rpc_id(1, username, password)
	username = ""
	password = ""

@rpc("authority", "call_remote", "reliable")
func ReturnLoginRequest(player_id, results, token):
	print("results received")
	smapi.connected_to_server.disconnect(_on_connection_succeed)
	smapi.server_disconnected.disconnect(_on_connection_disconnect)
	smapi.connection_failed.disconnect(_on_connection_fail)
	if results == true:
		print("Connecting to server...")
		GameServer.token = token
		GameServer.ConnectToServer()
	else:
		print("Please provide correct username and password")
	disconnected.emit()



func peer_connected(id: int) -> void:
	print("Peer connected to gateway: " + str(id))
func peer_disconnected(id: int) -> void:
	print("Peer disconnected from gateway: " + str(id))
