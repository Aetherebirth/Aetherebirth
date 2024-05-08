extends Node
class_name Connection

signal connected
signal disconnected

static var is_peer_connected: bool

@export var default_port: int = 6942
@export var max_clients: int
@export var use_localhost_in_editor: bool


func _ready() -> void:
	connected.connect(func(): Connection.is_peer_connected = true)
	disconnected.connect(func(): Connection.is_peer_connected = false)
	disconnected.connect(disconnect_all)

func start_client(ip, port) -> void:
	var address = ip
	if OS.has_feature("editor") and use_localhost_in_editor:
		address = "127.0.0.1"
	
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(address, port)
	if err != OK:
		print("Cannot start client. Err: " + str(err))
		disconnected.emit()
		return
	else: print("Connecting to server...")
	
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.server_disconnected.connect(server_connection_failure)
	multiplayer.connection_failed.connect(server_connection_failure)


func connected_to_server() -> void:
	print("Connected to server")
	connected.emit()


func server_connection_failure() -> void:
	print("Disconnected")
	disconnected.emit()


func peer_connected(id: int) -> void:
	print("Peer connected: " + str(id))


func peer_disconnected(id: int) -> void:
	print("Peer disconnected: " + str(id))


func disconnect_all() -> void:
	multiplayer.peer_connected.disconnect(peer_connected)
	multiplayer.peer_disconnected.disconnect(peer_disconnected)
	multiplayer.connected_to_server.disconnect(connected_to_server)
	multiplayer.server_disconnected.disconnect(server_connection_failure)
	multiplayer.connection_failed.disconnect(server_connection_failure)
