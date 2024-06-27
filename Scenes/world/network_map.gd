extends Node2D
## Multiplayer map manager

@rpc("any_peer")
func AskChunks(pos: Vector2, radius: int) -> void:
	AskChunks.rpc_id(1, pos, radius)

@rpc("authority")
func ReceiveChunks(chunks: Dictionary) -> void:
	print("Received %d chunks !"%chunks.size())
