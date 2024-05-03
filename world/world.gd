extends Node2D


@onready var maps = $Maps
@onready var player = $Player

@onready var chunk_manager = load("res://world/chunkmanager.gd").new(maps, player)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	chunk_manager._process(delta)
	pass
