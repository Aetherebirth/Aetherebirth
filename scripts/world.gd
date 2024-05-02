extends Node2D

@onready var maps = $Maps

# Called when the node enters the scene tree for the first time.
func _ready():
	var scene = load("res://scenes/chunks/map_test.tscn").instantiate()
	maps.add_child(scene)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
