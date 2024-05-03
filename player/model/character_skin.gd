class_name CharacterSkin
extends Node3D

# False : set animation to "idle"
# True : set animation to "move"
@onready var moving : bool = false : set = set_moving

# Blend value between the walk and run cycle
# 0.0 walk - 1.0 run
@onready var move_speed : float = 0.0 : set = set_moving_speed


func _ready():
	pass


@rpc("authority", "call_local", "unreliable_ordered")
func set_moving(value : bool):
	moving = value


@rpc("authority", "call_local", "unreliable_ordered")
func set_moving_speed(value : float):
	move_speed = clamp(value, 0.0, 1.0)


@rpc("authority", "call_local", "unreliable_ordered")
func fall():
	pass

