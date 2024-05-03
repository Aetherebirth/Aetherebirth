extends Node2D


@onready var maps = $Maps
@onready var player = $Player
@onready var chunk_manager

func _ready():
	start_chunk_manager()

func start_chunk_manager():
	chunk_manager = load("res://world/chunkmanager.gd").new(maps, player)

func _process(delta):
	if chunk_manager:
		chunk_manager._process(delta)
	pass
