extends Control
class_name Chat

@onready var chat_box: Dictionary = {
	"global": $ChatContainer/TabContainer/Global,
	"guild": $ChatContainer/TabContainer/Guild,
	"squad": $ChatContainer/TabContainer/Squad,
}
@onready var chat_input: LineEdit = $ChatContainer/HBoxContainer/ChatInput
@onready var tab_container: TabContainer = $ChatContainer/TabContainer

func add_message(author_id: int, message: String, tab: String) -> void:
	var author_name: String
	if(author_id==multiplayer.get_unique_id()):
		author_name = "Me"
	elif(author_id==1):
		author_name = "System"
	elif(GameServer.players.keys().has(author_id)):
		author_name = GameServer.players[author_id].name
	else:
		return;
	(chat_box.get(tab) as RichTextLabel).append_text("\n[%s] %s"%[author_name, message])


func add_username_message(username: String, message: String, tab: String) -> void:
	(chat_box.get(tab) as RichTextLabel).append_text("\n[%s] %s"%[username, message])

func show_text(text: String, tab: String) -> void:
	if(tab=="all"):
		for tab_name: String in chat_box.keys():
			(chat_box.get(tab_name) as RichTextLabel).append_text("\n%s"%text)
	else:
		(chat_box.get(tab) as RichTextLabel).append_text("\n%s"%text)


@onready var tabs: Array = chat_box.keys()
func _on_send_button_pressed() -> void:
	send_message()
func _on_chat_input_text_submitted(new_text: String) -> void:
	send_message()
	
func send_message() -> void:
	if(len(chat_input.text)>0):
		GameServer.SendChatMessage(chat_input.text, (tabs[tab_container.current_tab] as String))
		chat_input.clear()

