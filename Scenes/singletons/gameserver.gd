extends Node

signal connected
signal disconnected

@export var default_port: int = 6944
@export var max_clients: int
@export var default_ip: String = "127.0.0.1"
@export var use_localhost_in_editor: bool
var token: String

var latency: int = 0
var latency_array: Array[int] = []
var client_clock: float = 0
var decimal_collector: float = 0
var delta_latency: float = 0

var players: Dictionary = {}

func _physics_process(delta: float) -> void:
	client_clock += int(delta*1000) + delta_latency
	delta_latency -= delta_latency
	decimal_collector += delta*1000 - int(delta*1000)
	if(decimal_collector>=1.00):
		client_clock += 1
		decimal_collector -= 1.00
	

func ConnectToServer(address:String=default_ip) -> void:
	get_tree().change_scene_to_file("res://Scenes/main/game.tscn")
	#get_tree().change_scene_to_file("res://Scenes/character_selector/character_creator.tscn")
	var network: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	print("Connecting to the server - %s" %address)
	network.create_client(address,default_port)
	self.multiplayer.multiplayer_peer = network
	
	self.multiplayer.connected_to_server.connect(_connected_to_server)
	self.multiplayer.connection_failed.connect(_connection_failed)
	self.multiplayer.server_disconnected.connect(_disconnected_from_server)


@rpc("any_peer", "reliable")
func FetchPlayerStats() -> void:
	print("Requesting player stats from server")
	FetchPlayerStats.rpc_id(1)

@rpc("authority", "call_remote", "reliable")
func ReturnPlayerStats(results: Dictionary) -> void:
	print(results)

@rpc("authority", "call_remote", "reliable")
func FetchToken() -> void:
	print("Server is asking for token. Sending...")
	ReturnToken(token)

@rpc("any_peer", "call_remote", "reliable")
func ReturnToken(_token: String) -> void:
	ReturnToken.rpc_id(1, _token)

@rpc("authority", "call_remote", "reliable")
func ReturnTokenVerificationResults(result: bool) -> void:
	print("Received token verification results: "+str(result))
	# Switch to selector or back to login
	if(result):
		get_node("/root/Game/World/Player").set_physics_process(true)

@rpc("authority", "call_remote", "reliable")
func SpawnNewPlayer(player_id: int, position: Vector2) -> void:
	if(multiplayer.get_unique_id()==player_id):
		pass
	else:
		(get_node("/root/Game/World") as World).SpawnNewEntity(str(player_id), EntityHelper.Type.PLAYER, position)
	
@rpc("authority", "call_remote", "reliable")
func DespawnPlayer(player_id: int) -> void:
	(get_node("/root/Game/World") as World).DespawnPlayer(player_id)


@rpc("any_peer", "call_remote", "unreliable")
func SendPlayerState(player_state: Dictionary) -> void:
	SendPlayerState.rpc_id(1, player_state)


@rpc("any_peer", "call_remote", "unreliable")
func SendWorldState(world_state: Dictionary) -> void:
	(get_node("/root/Game/World") as World).UpdateWorldState(world_state)




func _connection_failed() -> void:
	print("Connection to game server failed")
	disconnected.emit()
func _connected_to_server() -> void:
	print("Connected to game server")
	#FetchPlayerStats()
	var latencyTimer: Timer = Timer.new()
	latencyTimer.wait_time = .5
	latencyTimer.autostart = true
	latencyTimer.connect("timeout", FetchServerTime.bind(client_clock))
	var timeTimer: Timer = Timer.new()
	timeTimer.wait_time = 5
	timeTimer.autostart = true
	timeTimer.connect("timeout", DetermineLatency)
	add_child(latencyTimer)
	add_child(timeTimer)
	

@rpc("any_peer", "call_remote", "reliable")
func FetchServerTime(client_time: int) -> void:
	FetchServerTime.rpc_id(1, int(Time.get_unix_time_from_system()*1000))

@rpc("authority", "call_remote", "reliable")
func ReturnServerTime(server_time: int, client_time: int) -> void:
	latency = float(int(Time.get_unix_time_from_system()*1000) - client_time) / 2
	client_clock = server_time + latency

@rpc("any_peer", "call_remote", "reliable")
func DetermineLatency() -> void:
	DetermineLatency.rpc_id(1, int(Time.get_unix_time_from_system()*1000))

@rpc("authority", "call_remote", "reliable")
func ReturnLatency(client_time: int) -> void:
	latency_array.append(float(int(Time.get_unix_time_from_system()*1000)-client_time)/2)
	if(latency_array.size()==9):
		var total_latency: float = 0
		latency_array.sort()
		var mid_point: float = latency_array[4]
		for i: int in range(latency_array.size()-1, -1, -1):
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
func AskEntityData(entity_type: EntityHelper.Type, entity_id: String) -> void:
	AskEntityData.rpc_id(1, entity_type, entity_id)

@rpc("authority", "call_remote", "reliable")
func ReceiveEntityData(entity_type: EntityHelper.Type, entity_id: String, data: Dictionary) -> void:
	var remote_entity: Entity = get_node("/root/Game/World/Entities/%s/%s"%[entity_type, entity_id])
	if(entity_type==EntityHelper.Type.PLAYER):
		players[entity_id] = data
		remote_entity.data = data
		(remote_entity as Player).SetName(data.name as String)
	elif(entity_type==EntityHelper.Type.NPC):
		(remote_entity as NPC).SetName(data.name as String)


## Chat system
@rpc("any_peer", "call_remote", "reliable")
func SendChatMessage(message: String, tab: String) -> void:
	SendChatMessage.rpc_id(1, message, tab)
@rpc("authority", "call_remote", "reliable")
func BroadcastChatMessage(player_id: int, message: String, tab: String)-> void:
	print("%s:%s"%[str(player_id), message])
	(get_node("/root/Game/World/Player/CameraController/Chat") as Chat).add_message(player_id, message, tab)

@rpc("authority", "call_remote", "reliable")
func ShowChatText(text: String) -> void:
	(get_node("/root/Game/World/Player/CameraController/Chat") as Chat).show_text(text, "all")
	

@rpc("authority", "call_remote", "reliable")
func SendGlobalChatMessage(username: String, escaped_message: String) -> void:
	(get_node("/root/Game/World/Player/CameraController/Chat") as Chat).add_username_message(username, escaped_message, "global")

@rpc("authority", "call_remote", "reliable")
func SendGuildChatMessage(username: String, escaped_message: String) -> void:
	(get_node("/root/Game/World/Player/CameraController/Chat") as Chat).add_username_message(username, escaped_message, "guild")
