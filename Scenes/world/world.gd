extends Node2D
class_name World


@onready var map: Node2D = $Map
@onready var player: PlayerController = $Player
@onready var chunk_manager: ChunkManager

var last_world_state: int = 0
var world_state_buffer: Array[Dictionary] = []

const interpolation_offset: int = 100

var spawn: Dictionary = {
	EntityHelper.Type.PLAYER: preload("res://Scenes/entity/playerlikeentity/player/player_template.tscn"),
	EntityHelper.Type.NPC: preload("res://Scenes/entity/playerlikeentity/npc/npc_template.tscn")
}

func _ready() -> void:
	create_entity_stores()
	start_chunk_manager()

func create_entity_stores() -> void:
	for entity_type: int in EntityHelper.Type.values():
		var entity_container: Node2D = Node2D.new()
		entity_container.name = str(entity_type)
		get_node("Entities").add_child(entity_container)

func start_chunk_manager() -> void:
	chunk_manager = ChunkManager.new(map, player)

func _process(delta: float) -> void:
	if chunk_manager:
		chunk_manager._process(delta)


func SpawnNewEntity(entity_id: String, entity_type: EntityHelper.Type, _position: Vector2) -> void:
	print("Entity %s spawned !" % entity_id)
	if not get_node("Entities/%s"%entity_type).has_node(str(entity_id)) and entity_id!=str(multiplayer.get_unique_id()):
		var new_entity: Entity = (spawn[entity_type] as PackedScene).instantiate()
		print(new_entity)
		new_entity.position = _position
		new_entity.SetId(str(entity_id))
		print(entity_type)
		get_node("Entities/%s"%entity_type).add_child(new_entity)
		
		GameServer.AskEntityData(entity_type, entity_id)

func DespawnPlayer(player_id: int) -> void:
	print("Player %d despawned" % player_id)
	await get_tree().create_timer(0.2).timeout
	if get_node("Entities/player/%d" % player_id): get_node("Entities/player/%d" % player_id).queue_free()

func UpdateWorldState(world_state: Dictionary) -> void:
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)

func _physics_process(_delta: float) -> void:
	var render_time: int = GameServer.client_clock - interpolation_offset
	if(world_state_buffer.size()>1):
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.pop_front()
		if(world_state_buffer.size()>2): # If we have a future state
			var interpolation_factor: float = (
				render_time - (world_state_buffer[1].T as float)
			) / ((world_state_buffer[2].T as float) - (world_state_buffer[1].T as float))
			
			print(world_state_buffer[2].entities)
			for entity_type: EntityHelper.Type in (world_state_buffer[2].entities as Dictionary).keys():
				for entity_id: String in (world_state_buffer[2].entities[entity_type] as Dictionary).keys():
					if entity_id == str(multiplayer.get_unique_id()):
						continue
					if not (world_state_buffer[1].entities[entity_type] as Dictionary).has(entity_id):
						continue
					if get_node("Entities/%s"%entity_type).has_node(str(entity_id)):
						var new_position: Vector2 = lerp(
							world_state_buffer[1].entities[entity_type][entity_id].P,
							world_state_buffer[2].entities[entity_type][entity_id].P,
							interpolation_factor
						)
						(get_node("Entities/%s/%s" % [entity_type, entity_id]) as Entity).MoveTo(new_position)
					else:
						print("Spawning entity %s"%entity_id)
						SpawnNewEntity(entity_id, entity_type, world_state_buffer[2].entities[entity_type][entity_id].P as Vector2)
					
		elif(render_time > world_state_buffer[1].T): # We have no future world state
			var extrapolation_factor: float = (
				render_time - world_state_buffer[0].T as float
			) / (world_state_buffer[1].T as float - world_state_buffer[0].T as float) - 1.00
			for player_id: String in (world_state_buffer[1].entities[EntityHelper.Type.PLAYER] as Dictionary).keys():
				if player_id == str(multiplayer.get_unique_id()):
					continue
				if not (world_state_buffer[0].entities[EntityHelper.Type.PLAYER] as Dictionary).has(player_id):
					continue
				if get_node("Entities/%s"%EntityHelper.Type.PLAYER).has_node(str(player_id)):
					var position_delta: Vector2 = (world_state_buffer[1].entities[EntityHelper.Type.PLAYER][player_id].P - world_state_buffer[0].entities[EntityHelper.Type.PLAYER][player_id].P)
					var new_position: Vector2 = world_state_buffer[1].entities[EntityHelper.Type.PLAYER][player_id].P + (position_delta*extrapolation_factor)
					(get_node("Entities/%s/%s"%[EntityHelper.Type.PLAYER, player_id]) as Entity).MoveTo(new_position)
				
			

