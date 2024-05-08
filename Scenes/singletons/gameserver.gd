extends Node

signal connected
signal disconnected

@export var default_port: int = 6944
@export var max_clients: int
@export var default_ip: String = "127.0.0.1"
@export var use_localhost_in_editor: bool

var token

func _ready():
	pass

func ConnectToServer():
	get_tree().change_scene_to_file("res://Scenes/main/game.tscn")
	#get_tree().change_scene_to_file("res://Scenes/character_selector/character_creator.tscn")
	var network = ENetMultiplayerPeer.new()
	print("Connecting to the server !")
	network.create_client(default_ip,default_port)
	self.multiplayer.multiplayer_peer = network
	
	self.multiplayer.connected_to_server.connect(_connected_to_server)
	self.multiplayer.connection_failed.connect(_connection_failed)
	self.multiplayer.server_disconnected.connect(_disconnected_from_server)


@rpc("any_peer", "reliable")
func FetchPlayerStats():
	print("Requesting player stats from server")
	FetchPlayerStats.rpc_id(1)

@rpc("authority", "call_remote", "reliable")
func ReturnPlayerStats( results):
	print(results)

@rpc("authority", "call_remote", "reliable")
func FetchToken():
	print("Server is asking for token. Sending...")
	ReturnToken(token)

@rpc("any_peer", "call_remote", "reliable")
func ReturnToken(_token):
	ReturnToken.rpc_id(1, _token)

@rpc("authority", "call_remote", "reliable")
func ReturnTokenVerificationResults(result):
	print("Received token verification results: "+str(result))
	# Switch to selector or back to login
	if(result):
		get_node("/root/Game/World/Player").set_physics_process(true)

@rpc("authority", "call_remote", "reliable")
func SpawnNewPlayer(player_id, position):
	if(multiplayer.get_unique_id()==player_id):
		pass
	else:
		get_node("/root/Game/World").SpawnNewPlayer(player_id, position)
	
@rpc("authority", "call_remote", "reliable")
func DespawnPlayer(player_id):
	get_node("/root/Game/World").DespawnPlayer(player_id)


@rpc("any_peer", "call_remote", "unreliable")
func SendPlayerState(player_state):
	SendPlayerState.rpc_id(1, player_state)


@rpc("any_peer", "call_remote", "unreliable")
func SendWorldState(world_state):
	get_node("/root/Game/World").UpdateWorldState(world_state)




func _connection_failed() -> void:
	print("Connection to game server failed")
	disconnected.emit()
func _connected_to_server() -> void:
	print("Connected to game server")
	#FetchPlayerStats()

func _disconnected_from_server() -> void:
	print("Disconnected from game server")
