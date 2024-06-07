extends Node2D


@onready var maps = $Maps
@onready var player = $Player
@onready var chunk_manager

var last_world_state = 0
var world_state_buffer = []

const interpolation_offset = 100

var player_spawn = preload("res://Scenes/player/player_template.tscn")

func _ready():
	start_chunk_manager()

func start_chunk_manager():
	chunk_manager = load("res://Scenes/world/chunkmanager.gd").new(maps, player)

func _process(delta):
	if chunk_manager:
		chunk_manager._process(delta)


func SpawnNewPlayer(player_id, _position):
	print("Player %d spawned !" % player_id)
	if not get_node("Entities/Players").has_node(str(player_id)) and player_id!=multiplayer.get_unique_id():
		var new_player = player_spawn.instantiate()
		new_player.position = _position
		new_player.name = str(player_id)
		get_node("Entities/Players").add_child(new_player)
		GameServer.AskPlayerData(player_id)

func DespawnPlayer(player_id):
	print("Player %d despawned" % player_id)
	await get_tree().create_timer(0.2).timeout
	get_node("Entities/Players/%d" % player_id).queue_free()

func UpdateWorldState(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)

func _physics_process(_delta):
	var render_time = GameServer.client_clock - interpolation_offset
	if(world_state_buffer.size()>1):
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.pop_front()
		if(world_state_buffer.size()>2): # If we have a future state
			var interpolation_factor = float(
				render_time - world_state_buffer[1].T
			) / float(world_state_buffer[2].T - world_state_buffer[1].T)
			for player_id in world_state_buffer[2].keys():
				if str(player_id)=="T":
					continue
				if player_id == multiplayer.get_unique_id():
					continue
				if not world_state_buffer[1].has(player_id):
					continue
				if get_node("Entities/Players").has_node(str(player_id)):
					var new_position = lerp(world_state_buffer[1][player_id].P, world_state_buffer[2][player_id].P, interpolation_factor)
					get_node("Entities/Players/%d" % player_id).MoveTo(new_position)
				else:
					print("Spawning player %d"%player_id)
					SpawnNewPlayer(player_id, world_state_buffer[2][player_id].P)
		elif(render_time > world_state_buffer[1].T): # We have no future world state
			var extrapolation_factor = float(
				render_time - world_state_buffer[0].T
			) / float(world_state_buffer[1].T - world_state_buffer[0].T) - 1.00
			for player_id in  world_state_buffer[1].keys():
				if str(player_id)=="T":
					continue
				if player_id == multiplayer.get_unique_id():
					continue
				if not world_state_buffer[0].has(player_id):
					continue
				if get_node("Entities/Players").has_node(str(player_id)):
					var position_delta = (world_state_buffer[1][player_id].P - world_state_buffer[0][player_id].P)
					var new_position = world_state_buffer[1][player_id].P + (position_delta*extrapolation_factor)
					get_node("Entities/Players/%d" % player_id).MoveTo(new_position)
				
			

