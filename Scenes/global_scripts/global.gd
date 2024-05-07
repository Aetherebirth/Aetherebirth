extends Node

var body_collection = {
	"1" : preload("res://assets/sprites/player/body/body1.png")
}

var eyeL_collection = {
	"1" : preload("res://assets/sprites/player/eyeL/eyeL1.png"),
	"none" : null
}

var eyeR_collection = {
	"1" : preload("res://assets/sprites/player/eyeR/eyeR1.png"),
	"none" : null
}

var shirt_collection = {
	"1" : preload("res://assets/sprites/player/shirt/shirt1.png")
}

var pants_collection = {
	"1" : preload("res://assets/sprites/player/pants/pants1.png")
}

var shoes_collection = {
	"1" : preload("res://assets/sprites/player/shoes/shoes1.png")
}

var hair_collection = {
	"1" : preload("res://assets/sprites/player/hair/hair1.png"),
	"2" : preload("res://assets/sprites/player/hair/hair2.png"),
	"3" : preload("res://assets/sprites/player/hair/hair3.png"),
	"none" : null
}

# Default values for colors
var body_color = Color(1.00, 0.81, 0.71)

var eyeL_color = Color(0.70, 0.54, 0.95)

var eyeR_color = Color(0.70, 0.54, 0.95)

var shirt_color = Color(0.92, 0.82, 0.73)

var pants_color = Color(0.67, 0.79, 0.91)

var shoes_color = Color(0.92, 0.82, 0.73)

var hair_color = Color(0.82, 0.82, 0.82)


# Selected values
var selected_body = ""
var selected_eyeL = ""
var selected_eyeR = ""
var selected_shirt = ""
var selected_pants = ""
var selected_shoes = ""
var selected_hair = ""

var player_name = ""
