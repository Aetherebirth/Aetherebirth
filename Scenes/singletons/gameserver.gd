extends Node

signal connected
signal disconnected

@export var default_port: int = 6944
@export var max_clients: int
@export var default_ip: String = "127.0.0.1"
@export var use_localhost_in_editor: bool
var token

var latency = 0
var latency_array = []
var client_clock = 0
var decimal_collector : float = 0
var delta_latency = 0

var players = {}

func _physics_process(delta):
	client_clock += int(delta*1000) + delta_latency
	delta_latency -= delta_latency
	decimal_collector += delta*1000 - int(delta*1000)
	if(decimal_collector>=1.00):
		client_clock += 1
		decimal_collector -= 1.00
	
	

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
	var timer = Timer.new()
	timer.wait_time = .5
	timer.autostart = true
	timer.connect("timeout", DetermineLatency)
	add_child(timer)

@rpc("any_peer", "call_remote", "reliable")
func FetchServerTime(client_time):
	FetchServerTime.rpc_id(1, int(Time.get_unix_time_from_system()*1000))

@rpc("authority", "call_remote", "reliable")
func ReturnServerTime(player_id, server_time, client_time):
	latency = (int(Time.get_unix_time_from_system()*1000) - client_time) / 2
	client_clock = server_time + latency

@rpc("any_peer", "call_remote", "reliable")
func DetermineLatency():
	DetermineLatency.rpc_id(1, int(Time.get_unix_time_from_system()*1000))

@rpc("authority", "call_remote", "reliable")
func ReturnLatency(client_time):
	latency_array.append((int(Time.get_unix_time_from_system()*1000)-client_time)/2)
	if(latency_array.size()==9):
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size()-1, -1, -1):
			if(latency_array[i]) > (2*mid_point) and latency_array[i] > 20:
				latency_array.erase(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		print("New latency: %f"%latency)
		latency_array.clear()

func _disconnected_from_server() -> void:
	print("Disconnected from game server")


@rpc("any_peer", "call_remote", "reliable")
func AskPlayerData(player_id):
	AskPlayerData.rpc_id(1, player_id)

@rpc("authority", "call_remote", "reliable")
func ReceivePlayerData(player_id, data):
	players[player_id] = data
	var remote_player = get_node("/root/Game/World/Players/%s"%player_id)
	remote_player.data = data
	remote_player.SetName(data.username)


## Chat system
@rpc("any_peer", "call_remote", "reliable")
func SendChatMessage(message, tab):
	SendChatMessage.rpc_id(1, message, tab)
@rpc("authority", "call_remote", "reliable")
func BroadcastChatMessage(player_id: int, message: String, tab: String):
	print("%s:%s"%[str(player_id), message])
	get_node("/root/Game/World/Player/CameraController/Chat").add_message(player_id, message, tab)

@rpc("authority", "call_remote", "reliable")
func ShowChatText(text: String):
	get_node("/root/Game/World/Player/CameraController/Chat").show_text(text, "all")
	
