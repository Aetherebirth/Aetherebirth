extends Control

@onready var chat_box = {
	"server": $ChatContainer/TabContainer/Server,
	"squad": $ChatContainer/TabContainer/Squad,
}
@onready var chat_input = $ChatContainer/HBoxContainer/ChatInput
@onready var tab_container = $ChatContainer/TabContainer

func add_message(author_id: int, message: String, tab: String):
	var author_name: String
	if(author_id==multiplayer.get_unique_id()):
		author_name = "Me"
	elif(author_id==1):
		author_name = "System"
	elif(GameServer.players.keys().has(author_id)):
		author_name = GameServer.players[author_id].username
	else:
		return;
	chat_box[tab].append_text("\n[%s] %s"%[author_name, message])

func show_text(text: String, tab: String):
	if(tab=="all"):
		for tab_name in chat_box.keys():
			chat_box[tab_name].append_text("\n%s"%text)
	else:
		chat_box[tab].append_text("\n%s"%text)

var tabs = ["server", "squad"]

func _on_send_button_pressed():
	send_message()
func _on_chat_input_text_submitted(new_text):
	send_message()
	
func send_message():
	if(len(chat_input.text)>0):
		GameServer.SendChatMessage(chat_input.text, tabs[tab_container.current_tab])
		chat_input.clear()

