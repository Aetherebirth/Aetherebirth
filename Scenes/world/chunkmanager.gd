class_name ChunkManager extends Node

const chunk_size: int = 32 # Chunk width and heigth
const tile_size: int = 16
const render_distance: int = 1

var current_chunk: Vector2 = Vector2()
var previous_chunk: Vector2 = Vector2()
var chunk_loaded: bool = false
var dimension: String = "overworld"

var circumnavigation: bool = false
var revolution_distance: int = 64

var player: CharacterBody2D
var map: Node2D

# Dictionary of dimensions as keys and dictionary of chunkpos: chunknode as value 
var active_chunks: Dictionary = {
	"overworld": {}
}

func _ready() -> void:
	current_chunk = _get_player_chunk(player.global_position)
	load_chunk()

# Check if the player is in a new chunk evevry frame
# If not, load the new chunks
func _process(_delta: float) -> void:
	current_chunk = _get_player_chunk(player.global_position)
	if (previous_chunk != current_chunk) and (!chunk_loaded):
		load_chunk()
	else:
		chunk_loaded = false
	previous_chunk = current_chunk

# This converts the players position to it's chunk coordinates
# subtracting one from the range lerp just makes sure that the chunk is actually changed when it's on
# the negative side.
func _get_player_chunk(pos: Vector2) -> Vector2:
	var chunk_pos: Vector2 = Vector2()
	chunk_pos.y = int((pos.y/chunk_size)/tile_size)
	chunk_pos.x = int((pos.x/chunk_size)/tile_size)
	if pos.x < 0:
		chunk_pos.x -= 1
	if pos.y < 0:
		chunk_pos.y -= 1
	return chunk_pos

#The render bound in the rect width of the render distance. ie render distance of 2
#will be multiplied by 2 to make it 4 the +1 which makes it 5, 5 chunks on the x and y axis with 
#a render distance of 2
func load_chunk() -> void:
	var render_bounds: float = render_distance*2 + 1
	#if x = 0, then x+1 = 1
	#if render_bounds = 5 (render distance = 2) then 5/2 = 2.5, (round(2.5)) = 3
	#then 1 - 3 = -2 which is the x coord in the chunk space, this same principle is used
	#for the y axis as well.
	for x: int in range(render_bounds):
		for y: int in range(render_bounds):
			var _x: int  = (x+1) - (round(render_bounds/2.0)) + current_chunk.x
			var _y: int  = (y+1) - (round(render_bounds/2.0)) + current_chunk.y
			
			var chunk_coords: Vector2 = Vector2(_x, _y)
			if !((active_chunks[dimension] as Dictionary).has(chunk_coords)):
				if(not (active_chunks[dimension] as Dictionary).has(chunk_coords)):
					_create_chunk(chunk_coords)

	for chunk_pos: Vector2 in (active_chunks[dimension] as Dictionary).keys():
		var chunk: Variant = active_chunks[dimension][chunk_pos]
		if chunk:
			print(chunk)
			if((abs(current_chunk.x-chunk_pos.x) > render_distance) and (abs(current_chunk.y-chunk_pos.y) > render_distance)):
				if typeof(chunk)!=TYPE_STRING: (chunk as Node2D).queue_free()
				(active_chunks[dimension] as Dictionary).erase(chunk_pos)

#this converts the chunks coords to it's key....
#this is for the circumanigation thing
func _get_chunk_key(coords: Vector2) -> Vector2:
	var key: Vector2 = coords
	if !circumnavigation:
		return key
	key.x = wrapf(coords.x, -revolution_distance, revolution_distance+1)
	return key
	
func _create_chunk(pos: Vector2) -> Node2D:
	var chunk_path : String = "res://Scenes/world/chunks/"+dimension+"/"+str(pos.x)+"_"+str(pos.y)+".tscn"
	if ResourceLoader.exists(chunk_path):
		var chunk_node: Node2D = (load(chunk_path) as PackedScene).instantiate()
		active_chunks[dimension][pos] = chunk_node
		chunk_node.global_position = pos * chunk_size * tile_size
		map.add_child(chunk_node)
		return chunk_node
	else:
		active_chunks[dimension][pos] = "ERR_DOES_NOT_EXIST"
		return Node2D.new()
	
func _init(map_node: Node2D, player_node: CharacterBody2D) -> void:
	map = map_node
	player = player_node
	#load_chunk()
	if(not (active_chunks[dimension] as Dictionary).has(player.global_position)):
		_create_chunk(_get_player_chunk(player.global_position))
	
	print("[ChunkLoader] Initialized")
