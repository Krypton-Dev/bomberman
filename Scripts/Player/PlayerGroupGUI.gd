extends VBoxContainer

onready var gm = $"/root/GameManager"
onready var player_label = $"Score/Label"
onready var score = $"Score"
onready var bombs = $"Bombs"
onready var inventory = $"Inventory"

export var player_id = 0

func _ready():
	visible = gm.get_player_count() >= player_id
	
	player_label.add_color_override("font_color", gm.get_player_color(player_id))
	player_label.text = gm.get_player_name(player_id)
	
	score.player_index = player_id
	bombs.player_id = player_id
	inventory.player_id = player_id
