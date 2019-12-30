extends VBoxContainer

onready var gm = $"/root/GameManager"

export var player_id = 0

func _ready():
	visible = gm.get_player_count() >= player_id
	print(player_id, " ", visible)
