extends CharacterBody2D
class_name Player

## Character maximum run speed on the ground.
@export var move_speed := 100.0
## Forward impulse after a melee attack.
@export var attack_impulse := 10.0
## Movement acceleration (how fast character achieve maximum speed)
@export var acceleration := 10
## Minimum horizontal speed on the ground. This controls when the character's animation tree changes
## between the idle and running states.
@export var stopping_speed := 1.0
## Clamp sync delta for faster interpolation
@export var sync_delta_max := 0.2

@onready var _camera_controller: CameraController = $CameraController
@onready var _synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

@onready var _move_direction := Vector2.ZERO
@onready var _last_strong_direction := Vector2.ZERO

## Sync properties
@export var _position: Vector2
@export var _velocity: Vector2
@export var _direction: Vector2 = Vector2.ZERO
@export var _strong_direction: Vector2 = Vector2.ZERO

# Player skin and name
@onready var body = $Skeleton/body
@onready var eyeL = $Skeleton/eyeL
@onready var eyeR = $Skeleton/eyeR
@onready var shirt = $Skeleton/shirt
@onready var pants = $Skeleton/pants
@onready var shoes = $Skeleton/shoes
@onready var hair = $Skeleton/hair
@onready var name_label = $Nickname/HBoxContainer/Nickname
@onready var animation_player = $AnimationPlayer

var position_before_sync: Vector2

var last_sync_time_ms: int
var sync_delta: float


func _ready() -> void:
	initialize_player()
	if is_multiplayer_authority():
		_camera_controller.setup(self)
	else:
		_synchronizer.delta_synchronized.connect(on_synchronized)
		_synchronizer.synchronized.connect(on_synchronized)
		on_synchronized()


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): interpolate_client(delta); return
	
	_move_direction = _get_input() * delta * move_speed
	
	# To not orient quickly to the last input, we save a last strong direction,
	# this also ensures a good normalized value for the rotation basis.
	if _move_direction.length() > 0.2:
		_last_strong_direction = _move_direction.normalized()
	
	#_orient_character_to_direction(_last_strong_direction, delta)
	
	velocity = velocity.lerp(_move_direction * move_speed, acceleration * delta)
	if _move_direction.length() == 0 and velocity.length() < stopping_speed:
		velocity = Vector2.ZERO
	
	# Set character animation
	if velocity.length() > stopping_speed:
		pass
		#_character_skin.set_moving.rpc(true)
		#_character_skin.set_moving_speed.rpc(inverse_lerp(0.0, move_speed, velocity.length()))
	else:
		pass
		#_character_skin.set_moving.rpc(false)
	if velocity.length() == 0:
		animation_player.play("idle_down")
	else:
		animation_player.play("RESET")
	
	var position_before := global_position
	move_and_slide()
	var position_after := global_position
	
	# If velocity is not 0 but the difference of positions after move_and_slide is,
	# character might be stuck somewhere!
	var delta_position := position_after - position_before
	var epsilon := 0.001
	if delta_position.length() < epsilon and velocity.length() > epsilon:
		global_position += get_wall_normal() * 0.1
	
	set_sync_properties()

func initialize_player():
	body.texture = Global.body_collection[Global.selected_body]
	body.modulate = Global.selected_body_color
	
	eyeL.texture = Global.eyeL_collection[Global.selected_eyeL]
	eyeL.modulate = Global.selected_eyeL_color

	eyeR.texture = Global.eyeR_collection[Global.selected_eyeR]
	eyeR.modulate = Global.selected_eyeR_color
	
	shirt.texture = Global.shirt_collection[Global.selected_shirt]
	shirt.modulate = Global.selected_shirt_color
	
	pants.texture = Global.pants_collection[Global.selected_pants]
	pants.modulate = Global.selected_pants_color
	
	shoes.texture = Global.shoes_collection[Global.selected_shoes]
	shoes.modulate = Global.selected_shoes_color

	hair.texture = Global.hair_collection[Global.selected_hair]
	hair.modulate = Global.selected_hair_color
	
	name_label.text =Global.player_name

func set_sync_properties() -> void:
	_position = position
	_velocity = velocity
	_direction = _move_direction
	_strong_direction = _last_strong_direction


func on_synchronized() -> void:
	velocity = _velocity
	position_before_sync = position
	
	var sync_time_ms = Time.get_ticks_msec()
	sync_delta = clampf(float(sync_time_ms - last_sync_time_ms) / 1000, 0, sync_delta_max)
	last_sync_time_ms = sync_time_ms


func interpolate_client(delta: float) -> void:
	#_orient_character_to_direction(_strong_direction, delta)
	
	if _direction.length() == 0:
		# Don't interpolate to avoid small jitter when stopping
		if (_position - position).length() > 1.0 and _velocity.is_zero_approx():
			position = _position # Fix misplacement
	else:
		# Interpolate between position_before_sync and _position
		# and add to ongoing movement to compensate misplacement
		var t = 1.0 if is_zero_approx(sync_delta) else delta / sync_delta
		sync_delta = clampf(sync_delta - delta, 0, sync_delta_max)
		
		var less_misplacement = position_before_sync.move_toward(_position, t)
		position += less_misplacement - position_before_sync
		position_before_sync = less_misplacement
	
	move_and_slide()


func _get_input() -> Vector2:
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	return raw_input


#func _orient_character_to_direction(direction: Vector2, delta: float) -> void:
#	pass


#@rpc("any_peer", "call_remote", "reliable")
func respawn(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
