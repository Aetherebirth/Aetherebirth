extends Node2D


@onready var maps = $Maps
@onready var player = $Player
@onready var chunk_manager

var last_world_state = 0

var player_spawn = preload("res://Scenes/player/player_template.tscn")

func _ready():
	start_chunk_manager()

func start_chunk_manager():
	chunk_manager = load("res://Scenes/world/chunkmanager.gd").new(maps, player)

func _process(delta):
	if chunk_manager:
		chunk_manager._process(delta)
	pass


func SpawnNewPlayer(player_id, position):
	print("Player %d spawned !" % player_id)
	if not get_node("Players").has_node(str(player_id)) and player_id!=multiplayer.get_unique_id():
		var new_player = player_spawn.instantiate()
		new_player.position = position
		new_player.name = str(player_id)
		get_node("Players").add_child(new_player)

func DespawnPlayer(player_id):
	print("Player %d despawned" % player_id)
	get_node("Players/%d" % player_id).queue_free()

func UpdateWorldState(world_state):
	# Buffer
	# Interpolation
	# Extrapolation
	# Rubber Banding
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state.erase("T") # We will need this later for inter/extrapolation, but not now

		world_state.erase(multiplayer.get_unique_id()) # Erase this player's entry, may need this later for anti-e
		for player_id in world_state.keys():
			if get_node("Players").has_node(str(player_id)):
				get_node("Players/%d" % player_id).MovePlayer(world_state[player_id]["P"])
			else:
				print("spawning player")
				SpawnNewPlayer(player_id, world_state[player_id]["P"])

