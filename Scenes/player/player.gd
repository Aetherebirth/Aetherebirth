extends CharacterBody2D
class_name Player

@export var move_speed := 100.0
@export var acceleration := 10
@export var stopping_speed := 1.0

@onready var _camera_controller: CameraController = $CameraController

@onready var _move_direction := Vector2.ZERO

# Player skin and name
@onready var body = $Skeleton/body
@onready var eyeL = $Skeleton/eyeL
@onready var eyeR = $Skeleton/eyeR
@onready var shirt = $Skeleton/shirt
@onready var pants = $Skeleton/pants
@onready var shoes = $Skeleton/shoes
@onready var hair = $Skeleton/hair
@onready var animation_player = $AnimationPlayer

var player_state

func _ready() -> void:
	initialize_player()
	_camera_controller.setup(self)
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	MovementLoop(delta)
	DefinePlayerState()
	
func MovementLoop(delta: float) -> void:
	_move_direction = _get_input() * delta * move_speed
	
	velocity = velocity.lerp(_move_direction * move_speed, acceleration * delta)
	if _move_direction.length() == 0 and velocity.length() < stopping_speed:
		velocity = Vector2.ZERO
	
	if velocity.length() == 0:
		animation_player.play("idle_down")
	else:
		animation_player.play("RESET")
	
	var position_before := global_position
	move_and_slide()
	var position_after := global_position
	
	var delta_position := position_after - position_before
	var epsilon := 0.001
	if delta_position.length() < epsilon and velocity.length() > epsilon:
		global_position += get_wall_normal() * 0.1

func DefinePlayerState():
	player_state = {"T": int(Time.get_unix_time_from_system()*1000), "P": get_global_position()}
	GameServer.SendPlayerState(player_state)



func initialize_player():
	body.texture = Global.body_collection[Global.selected_body]
	body.modulate = Global.body_color
	
	eyeL.texture = Global.eyeL_collection[Global.selected_eyeL]
	eyeL.modulate = Global.eyeL_color

	eyeR.texture = Global.eyeR_collection[Global.selected_eyeR]
	eyeR.modulate = Global.eyeR_color
	
	shirt.texture = Global.shirt_collection[Global.selected_shirt]
	shirt.modulate = Global.shirt_color
	
	pants.texture = Global.pants_collection[Global.selected_pants]
	pants.modulate = Global.pants_color
	
	shoes.texture = Global.shoes_collection[Global.selected_shoes]
	shoes.modulate = Global.shoes_color

	hair.texture = Global.hair_collection[Global.selected_hair]
	hair.modulate = Global.hair_color

func _get_input() -> Vector2:
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return raw_input

