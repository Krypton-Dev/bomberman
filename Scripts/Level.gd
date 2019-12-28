extends Node2D

var preview = false

func _ready():
	if not preview:
		var gm = get_node("/root/GameManager")
		gm.start_game()
