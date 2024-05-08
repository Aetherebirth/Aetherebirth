extends Node2D
class_name CameraController

var _anchor: CharacterBody2D
var _offset: Vector2
		
func _physics_process(delta: float) -> void:
	if not _anchor: return
	var target_position := _anchor.global_position + _offset
	global_position = target_position

func setup(anchor: CharacterBody2D) -> void:
	_anchor = anchor
	_offset = global_transform.origin - anchor.global_transform.origin
