extends CharacterBody2D
class_name Entity

var data: Dictionary = {}

func SetId(id: String) -> void:
	name = id

func MoveTo(_position: Vector2) -> void:
	global_position = _position
