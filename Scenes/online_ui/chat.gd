extends Control

@onready var chat_box = $ChatContainer/ChatBox
@onready var chat_input = $ChatContainer/HBoxContainer/ChatInput

func add_message(player_id, message):
	var author_name: String
	if(player_id==multiplayer.get_unique_id()):
		author_name = "Me"
	elif(GameServer.players.keys().has(player_id)):
		author_name = GameServer.players[player_id].username
	else:
		return;
	chat_box.text += "\n%s: %s"%[author_name, message]



func _on_send_button_pressed():
	if(len(chat_input.text)>0):
		GameServer.SendChatMessage(chat_input.text)
		chat_input.clear()
