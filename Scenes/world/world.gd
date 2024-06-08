extends Node2D


@onready var maps = $Maps
@onready var player = $Player
@onready var chunk_manager

var last_world_state = 0
var world_state_buffer = []

const interpolation_offset = 100

var spawn = {
	"player": preload("res://Scenes/player/player_template.tscn")
}

func _ready():
	start_chunk_manager()

func start_chunk_manager():
	chunk_manager = load("res://Scenes/world/chunkmanager.gd").new(maps, player)

func _process(delta):
	if chunk_manager:
		chunk_manager._process(delta)


func SpawnNewEntity(entity_id: String, entity_type: String, _position: Vector2):
	print("Entity %s spawned !" % entity_id)
	if not get_node("Entities/%s"%entity_type).has_node(str(entity_id)) and entity_id!=str(multiplayer.get_unique_id()):
		var new_entity = spawn[entity_type].instantiate()
		new_entity.position = _position
		new_entity.name = str(entity_id)
		print(entity_type)
		get_node("Entities/%s"%entity_type).add_child(new_entity)
		if entity_type == "player":
			GameServer.AskPlayerData(entity_id)
			print("Asked player data")

func DespawnPlayer(player_id):
	print("Player %d despawned" % player_id)
	await get_tree().create_timer(0.2).timeout
	if get_node("Entities/player/%d" % player_id): get_node("Entities/player/%d" % player_id).queue_free()

func UpdateWorldState(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)

func _physics_process(_delta):
	var render_time = GameServer.client_clock - interpolation_offset
	if(world_state_buffer.size()>1):
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.pop_front()
		if(world_state_buffer.size()>2): # If we have a future state
			var interpolation_factor = float(
				render_time - world_state_buffer[1].T
			) / float(world_state_buffer[2].T - world_state_buffer[1].T)
			
			for entity_type in world_state_buffer[2].entities.keys():
				for eid in world_state_buffer[2].entities[entity_type].keys():
					var entity_id = str(eid)
					if entity_id == str(multiplayer.get_unique_id()):
						continue
					if not world_state_buffer[1].entities[entity_type].has(entity_id):
						continue
					if get_node("Entities/%s"%entity_type).has_node(str(entity_id)):
						var new_position = lerp(
							world_state_buffer[1].entities[entity_type][entity_id].P,
							world_state_buffer[2].entities[entity_type][entity_id].P,
							interpolation_factor
						)
						get_node("Entities/%s/%s" % [entity_type, entity_id]).MoveTo(new_position)
					else:
						print("Spawning entity %s"%entity_id)
						SpawnNewEntity(entity_id, entity_type, world_state_buffer[2].entities.player[entity_id].P)
					
		elif(render_time > world_state_buffer[1].T): # We have no future world state
			var extrapolation_factor = float(
				render_time - world_state_buffer[0].T
			) / float(world_state_buffer[1].T - world_state_buffer[0].T) - 1.00
			for player_id in world_state_buffer[1].entities.player.keys():
				if player_id == str(multiplayer.get_unique_id()):
					continue
				if not world_state_buffer[0].entities.player.has(player_id):
					continue
				if get_node("Entities/player").has_node(str(player_id)):
					var position_delta = (world_state_buffer[1].entities.player[player_id].P - world_state_buffer[0].entities.player[player_id].P)
					var new_position = world_state_buffer[1].entities.player[player_id].P + (position_delta*extrapolation_factor)
					get_node("Entities/player/%d" % player_id).MoveTo(new_position)
				
			

