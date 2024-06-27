extends Entity
class_name PlayerLikeEntity

@onready var nickname: Label = $Nickname/HBoxContainer/Nickname

func SetName(_name: String) -> void:
	"""Set the displayed name of the entity to _name"""
	nickname.text = _name

func isNPC() -> bool:
	return false

func isPlayer() -> bool:
	return false
