extends Node

signal connected
signal disconnected

@export var default_port: int = 6944
@export var max_clients: int
@export var default_ip: String = "127.0.0.1"
@export var use_localhost_in_editor: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func ConnectToServer():
	get_tree().change_scene_to_file("res://Scenes/character_selector/character_creator.tscn")
	var network = ENetMultiplayerPeer.new()
	print("Connecting to the server !")
	network.create_client(default_ip,default_port)
	self.multiplayer.multiplayer_peer = network
	
	self.multiplayer.connected_to_server.connect(_connected_to_server)
	self.multiplayer.connection_failed.connect(_connection_failed)
	self.multiplayer.server_disconnected.connect(_disconnected_from_server)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _connection_failed() -> void:
	print("Connection to game server failed")
	disconnected.emit()
func _connected_to_server() -> void:
	print("Connected to game server")
func _disconnected_from_server() -> void:
	print("Disconnected from game server")
