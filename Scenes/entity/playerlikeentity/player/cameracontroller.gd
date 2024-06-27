extends Node2D
class_name CameraController

var _anchor: PlayerController
var _offset: Vector2
		
func _physics_process(_delta: float) -> void:
	if not _anchor: return
	var target_position: Vector2 = _anchor.global_position + _offset
	global_position = target_position

func setup(anchor: PlayerController) -> void:
	_anchor = anchor
	_offset = global_transform.origin - anchor.global_transform.origin
