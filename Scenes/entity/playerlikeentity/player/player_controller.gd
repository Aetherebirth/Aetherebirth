extends CharacterBody2D
class_name PlayerController

@export var move_speed: float = 100.0
@export var acceleration: int = 10
@export var stopping_speed: float = 1.0

@onready var _camera_controller: CameraController = $CameraController

@onready var _move_direction: Vector2 = Vector2.ZERO

# Player skin and name
@onready var body: Sprite2D = $Skeleton/body
@onready var eyeL: Sprite2D = $Skeleton/eyeL
@onready var eyeR: Sprite2D = $Skeleton/eyeR
@onready var shirt: Sprite2D = $Skeleton/shirt
@onready var pants: Sprite2D = $Skeleton/pants
@onready var shoes: Sprite2D = $Skeleton/shoes
@onready var hair: Sprite2D = $Skeleton/hair
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var _silhouette_sprite: Sprite2D = $SilhouetteSprite

var player_state: Dictionary

func _ready() -> void:
	initialize_player()
	_camera_controller.setup(self)
	set_physics_process(false)
	#_silhouette_sprite.texture = texture
	#_silhouette_sprite.offset = offset
	#_silhouette_sprite.flip_h = flip_h
	#_silhouette_sprite.hframes = hframes
	#_silhouette_sprite.vframes = vframes
	#_silhouette_sprite.frame = frame




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
	
	var position_before: Vector2 = global_position
	move_and_slide()
	var position_after: Vector2 = global_position
	
	var delta_position: Vector2 = position_after - position_before
	var epsilon: float = 0.001
	if delta_position.length() < epsilon and velocity.length() > epsilon:
		global_position += get_wall_normal() * 0.1

func DefinePlayerState() -> void:
	player_state = {"T": int(Time.get_unix_time_from_system()*1000), "P": get_global_position()}
	GameServer.SendPlayerState(player_state)



func initialize_player() -> void:
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
	var raw_input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return raw_input

func _set(property: StringName, value: Variant) -> bool:
	if is_instance_valid(_silhouette_sprite):
		match property:
			"texture":
				_silhouette_sprite.texture = value
			"offset":
				_silhouette_sprite.offset = value
			"flip_h":
				_silhouette_sprite.flip_h = value
			"hframes":
				_silhouette_sprite.hframes = value
			"vframes":
				_silhouette_sprite.vframes = value
			"frame":
				_silhouette_sprite.frame = value
	return false
