extends Node

var body_collection = {
	"1" : preload("res://assets/sprites/player/body/body1.png")
}

var eyeL_collection = {
	"none" : null,
	"1" : preload("res://assets/sprites/player/eyeL/eyeL1.png")
}

var eyeR_collection = {
	"none" : null,
	"1" : preload("res://assets/sprites/player/eyeR/eyeR1.png")
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
	"none" : null,
	"1" : preload("res://assets/sprites/player/hair/hair1.png")
}

# Skintones
var body_color = [
	Color(0.99, 0.91, 0.84),
	Color(1.00, 0.81, 0.71),
	Color(0.95, 0.80, 0.64),
	Color(0.92, 0.70, 0.51),
	Color(0.89, 0.60, 0.41),
	Color(0.83, 0.54, 0.29),
	Color(0.76, 0.44, 0.19),
	Color(0.64, 0.35, 0.13),
	Color(0.51, 0.35, 0.25),
	Color(0.51, 0.32, 0.16),
	Color(0.38, 0.16, 0.03),
	Color(0.22, 0.16, 0.09),
]

var eyeL_color = [
	Color(0.96, 0.80, 0.69), # Light
	Color(0.72, 0.54, 0.38), # Medium
	Color(0.45, 0.34, 0.27), # Brown
]

var eyeR_color = [
	Color(0.96, 0.80, 0.69), # Light
	Color(0.72, 0.54, 0.38), # Medium
	Color(0.45, 0.34, 0.27), # Brown
]

var shirt_color = [
	Color(0.96, 0.80, 0.69), # Light
	Color(0.72, 0.54, 0.38), # Medium
	Color(0.45, 0.34, 0.27), # Brown
]

var pants_color = [
	Color(0.96, 0.80, 0.69), # Light
	Color(0.72, 0.54, 0.38), # Medium
	Color(0.45, 0.34, 0.27), # Brown
]

var shoes_color = [
	Color(0.96, 0.80, 0.69), # Light
	Color(0.72, 0.54, 0.38), # Medium
	Color(0.45, 0.34, 0.27), # Brown
]

var hair_color = [
	Color(0.1, 0.1, 0.1), # Black
	Color(0.4, 0.2, 0.1), # Brown
	Color(0.9, 0.6, 0.2), # Blonde
]


# Selected values
var selected_body = ""
var selected_eyeL = ""
var selected_eyeR = ""
var selected_shirt = ""
var selected_pants = ""
var selected_shoes = ""
var selected_hair = ""
# Selected values for colors
var selected_body_color = ""
var selected_eyeL_color = ""
var selected_eyeR_color = ""
var selected_shirt_color = ""
var selected_pants_color = ""
var selected_shoes_color = ""
var selected_hair_color = ""

var player_name = ""
