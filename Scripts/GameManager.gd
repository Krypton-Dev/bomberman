extends Node

onready var nm = $"/root/NetworkManager"

var bomb = preload("res://Scripts/Bombs/Bomb.tscn")
var nuke = preload("res://Scripts/Bombs/Nuke.tscn")

var game_running = false

var player = preload("res://Scripts/Player/PlayerScene.tscn")
var item = preload("res://Scripts/Items/Item.tscn")
var current_scene = null
var respawn_time = 2

var item_id = 0

var next_item_drop = 0

var active_players = []
remote var player_scores = [ 0, 0, 0, 0 ] setget set_player_scores
remote var player_inventories = [
	null, null, null, null
] setget set_player_inventories

var propabilities = {
	0: {
		bomb=0.333
	}
}

signal player_score_updated
signal player_inventory_updated

func _ready():
	print("Start game")
	randomize()
	
	clear_inventories()

func _process(delta):
	if not game_running:
		return
	
	if not nm.is_network_game or nm.is_server:
		next_item_drop -= delta
		if next_item_drop <= 0:
			spawn_random_item()
		
func start_game():
	game_running = true
	
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
	if not nm.is_network_game or nm.is_server:
		clear_inventories()
		spawn_players()	
		
		spawn_random_item()
	
#####################################
############## PLAYERS ##############
#####################################

# Valid input_methods: keyboard[1-4], controller[device_id], network[peer_id]
func add_player(input_method):
	assert(active_players.size() < 4)
	
	active_players.append({
		input_method = input_method
	})
	
	print("current players ", active_players)
	
func get_player_count():
	return active_players.size()
	
func get_player(player_id):
	assert(player_id >= 1)
	assert(player_id <= active_players.size())
	
	return active_players[player_id-1]
		
###################################
############## SPAWN ##############
###################################

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
	for player_id in range(1, active_players.size() + 1):
		var pos = locations.pop_back()
		if nm.is_network_game:
			rpc("spawn_player", player_id, pos)
		else:
			spawn_player(player_id, pos)
		
remotesync func spawn_player(player_id, position):
	var playerInstance = player.instance()
	playerInstance.position = position
	playerInstance.player_id = player_id
	
	if nm.is_network_game:
		playerInstance.set_network_master(nm.get_peer_of_player(player_id))
	
	current_scene.add_child(playerInstance)
		
func respawn_player(player_id):
	var location = get_randomized_spawn_positions().pop_back()
	if nm.is_network_game:
		rpc("spawn_player", player_id, location)
	else:
		spawn_player(player_id, location)
	clear_inventory(player_id)

puppet func spawn_item(position:Vector2, item_type:String):
	var item_instance = item.instance()
	item_instance.name = "item" + str(item_id)
	item_instance.position = position
	item_instance.set_item_type(item_type)
	current_scene.add_child(item_instance)
	
	item_id += 1
	
	if nm.is_network_game and nm.is_server:
		rpc("spawn_item", position, item_type)

func spawn_random_item():
	next_item_drop = rand_range(3, 5)
	var valid_spaces = get_map_tiles(1 | 2 | 4)
			
	if valid_spaces.empty():
		print("no free spaces to spawn item!")
		return
	
	valid_spaces.shuffle()
	var random_pos = valid_spaces.pop_back()

	var item_type = "bomb"
	var rand_value = randf()
	if rand_value > 0.1 and rand_value <= 0.3:	# 20 %
		item_type = "random"
	if rand_value <= 0.1:						# 10 %
		item_type = "nuke"

	spawn_item(random_pos, item_type)
	
func get_map_tiles(collision_layer = 0):
	var background: TileMap = current_scene.get_node("Map Background")
	var valid_spaces = []
	for cell in background.get_used_cells():
		var abs_pos = cell * background.cell_size + background.cell_size / 2
		if collision_layer == 0 or not check_for_collision(1 | 2 | 4, abs_pos, true):
			valid_spaces.push_back(abs_pos)
			
	return valid_spaces
	
remote func spawn(type, player_id, position):
	var instance = null
	if type == "nuke":
		instance = nuke.instance()
		pass
	elif type == "bomb":
		instance = bomb.instance()
		pass
	else:
		return
		
	instance.player_id = player_id
	instance.position = position
	current_scene.add_child(instance)
	
	if nm.is_network_game and nm.get_peer_of_player(player_id) == get_tree().get_network_unique_id():
		rpc("spawn", type, player_id, position)

#######################################
############## INVENTORY ##############
#######################################

func clear_inventories():
	for player_id in range(1, 5):
		clear_inventory(player_id)
	
func clear_inventory(player_id):
	player_inventories[player_id-1] = {
		bomb = 3,
		nuke = 0
	}
	if nm.is_network_game:
		rset("player_inventories", player_inventories)
	
	emit_signal("player_inventory_updated", player_id)
	
func get_inventory(player_id):
	return player_inventories[player_id-1]
	
func check_free_space(player_id, item):
	assert(player_id >= 1 && player_id <= 4)
	var quantity = player_inventories[player_id-1][item] + 1
	
	return _ensure_storage(item, quantity) == quantity

func give_item(player_id, item, quantity = 1):
	assert(player_id >= 1 && player_id <= 4)
	player_inventories[player_id-1][item] = _ensure_storage(item, player_inventories[player_id-1][item] + quantity)
	if nm.is_network_game:
		rset("player_inventories", player_inventories)
	
	emit_signal("player_inventory_updated", player_id)
	
func remove_item(player_id, item, quantity = 1):
	give_item(player_id, item, -quantity)
	
func _ensure_storage(item, count):
	if item == "bomb":
		return min(4, max(0, count))
	if item == "nuke":
		return min(1, max(0, count))
		
	return count
	
func get_item_count(player_id, item):
	assert(player_id >= 1 && player_id <= 4)
	return player_inventories[player_id-1][item]
	
func has_item(player_id, item):
	return get_item_count(player_id, item) > 0
	
func set_player_inventories(value):
	player_inventories = value
	for i in range(1, 5):
		emit_signal("player_inventory_updated", i)

###################################
############## SCORE ##############
###################################

func grant_score(player_id, score = 1):
	print("grant score for ", player_id)
	player_scores[player_id-1] += score
	if player_scores[player_id-1] < 0:
		player_scores[player_id-1] = 0 # We don't allow negative score values!
		
	if nm.is_network_game:
		rset("player_scores", player_scores)
		
	emit_signal("player_score_updated", player_id)
	
func get_score(player_id):
	if player_id < 1 or player_id > 4:
		return -1
		
	return player_scores[player_id-1]

func set_player_scores(value):
	player_scores = value
	for i in range(1,5):
		emit_signal("player_score_updated", i)
#########################################
############## CHEAT CODES ##############
#########################################
var cheat_buffer = ""

func check_cheat_buffer():
	if cheat_buffer.ends_with("givemenuke"):
		give_item(1, "nuke")
		cheat_buffer = ""

func _input(event):
	if event is InputEventKey:
		var key = event.get_unicode()
		if key > 0:
			cheat_buffer += char(key)
			
		check_cheat_buffer()

#####################################
############## GENERAL ##############
#####################################

func getColor(player_id):
	if player_id == 1:
		return "Green"
	if player_id == 2:
		return "Red"
	if player_id == 3:
		return "Blue"
	if player_id == 4:
		return "Purple"
		
	return "Green"

func on_destoryable_destroyed(destroyable, player_id):
	if nm.is_network_game and nm.is_client:
		return
	
	if not propabilities.has(destroyable.type):
		return
	var props = propabilities[destroyable.type]
	
	for item_type in props.keys():
		if randf() <= props[item_type]:
			#give_item(player_id, item_type)
			spawn_item(destroyable.position, item_type)
			
func get_collisions(layer, abs_pos, areas = false, bodies = true, count = 1, excludes = []):	
	return current_scene.get_world_2d().direct_space_state.intersect_point(abs_pos, count, excludes, layer, bodies, areas)
			
func check_for_collision(layer, abs_pos, areas = false, bodies = true):	
	var collisions = get_collisions(layer, abs_pos, areas, bodies)
	return len(collisions) > 0
	
func get_player_color(player_id: int):
	if player_id == 1:
		return Color("28b162") # green
	if player_id == 2:
		return Color("a03939") # red
	if player_id == 3:
		return Color("398ea0") # blue 
	if player_id == 4:
		return Color("8739a0") # purple
		
	return Color("ffffff") # white
	
func get_player_name(player_id):
	if player_id == 1:
		return "Green"
	if player_id == 2:
		return "Red"
	if player_id == 3:
		return "Blue"
	if player_id == 4:
		return "Purple"
		
	return "???"
	
