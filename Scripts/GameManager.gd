extends Node

var player = preload("res://Scripts/Player/PlayerScene.tscn")
var current_scene = null
var respawn_time = 2


func _ready():
	print("Start game")
	
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
	spawn_players()
	
	
func get_randomized_spawn_positions():
	# Query spawn locations
	var locations = []
	for position in current_scene.get_node("spawn_positions").get_children():
		locations.push_back(position.position)
	randomize()
	locations.shuffle()
	return locations
	
func spawn_players():		
	var locations = get_randomized_spawn_positions()
	for player_id in range(1, 5):
		var playerInstance = player.instance()
		playerInstance.position = locations.pop_back()
		playerInstance.playerId = player_id
		current_scene.add_child(playerInstance)

func respawn_player(player_id):
	var location = get_randomized_spawn_positions().pop_back()
	var playerInstance = player.instance()
	playerInstance.position = location
	playerInstance.playerId = player_id
	current_scene.add_child(playerInstance)
	
		
func getColor(playerId):
	if playerId == 1:
		return "Green"
	if playerId == 2:
		return "Red"
	if playerId == 3:
		return "Blue"
	if playerId == 4:
		return "Purple"
		
	return "Green"