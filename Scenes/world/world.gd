extends Node2D


@onready var maps = $Maps
@onready var player = $Player
@onready var chunk_manager

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
	var new_player = player_spawn.instantiate()
	new_player.position = position
	new_player.name = str(player_id)
	get_node("Players").add_child(new_player)

func DespawnPlayer(player_id):
	print("Player %d despawned" % player_id)
	get_node("Players/%d" % player_id).queue_free()
