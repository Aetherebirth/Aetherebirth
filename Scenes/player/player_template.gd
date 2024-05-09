extends CharacterBody2D

var data = {}

func MovePlayer(_position):
	global_position = _position

func SetName(_name: String):
	$Nickname/HBoxContainer/Nickname.text = _name
