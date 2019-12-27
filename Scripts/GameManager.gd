extends Node

var player = preload("res://Scripts/Player/PlayerScene.tscn")
var current_scene = null

func _ready():
	print("Start game")
	
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
	spawn_players()
	
func spawn_players():
	# Query spawn locations
	var locations = []
	for position in current_scene.get_node("spawn_positions").get_children():
		locations.push_back(position.position)
	randomize()
	locations.shuffle()
	
	for player_id in range(1, 5):
		var playerInstance = player.instance()
		playerInstance.position = locations.pop_back()
		playerInstance.playerId = player_id
		current_scene.add_child(playerInstance)