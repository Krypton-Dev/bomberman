extends Node

var is_network_game = false
var is_server = false
var is_client = false
var connected = false

signal player_joined
signal player_left
signal server_joined
signal server_disconnect
signal change_level
signal start_game
signal refresh_inventory

var player_id_peers = [-1,-1,-1,-1]

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("server_disconnected", self, "_connection_closed")
	
func _connected_ok():
	connected = true
	emit_signal("server_joined")
	
func _connection_failed():
	connected = false
	emit_signal("server_disconnect")
	
func _connection_closed():
	connected = false
	emit_signal("server_disconnect")
	
func _player_disconnected(id):
	print(id, " disconnected")
	var remove_positions = []
	for i in range(0, 4):
		if player_id_peers[i] == id:
			player_id_peers[i] = -1
			remove_positions.push_back(i)
			emit_signal("player_left", i+1)
			
	for i in remove_positions:
		player_id_peers.remove(i)
		
	if player_id_peers.size() < 4:
		for i in range(player_id_peers.size(), 4):
			player_id_peers.push_back(-1)
			
func _player_connected(id):
	for i in range(0, 4):
		if player_id_peers[i] != id and player_id_peers[i] != -1:
			rpc_id(id, "add_player", i+1, player_id_peers[i])
	
func enable_server():
	is_network_game = true
	is_server = true
	is_client = false
	connected = true
	
func enable_client():
	is_network_game = true
	is_server = false
	is_client = true
	connected = false
	
func close_server():
	get_tree().set_refuse_new_network_connections(true)
	
func get_peer_of_player(player_id):
	return player_id_peers[player_id-1]
	
func send_add_player(player_id):
	player_id_peers[player_id-1] = get_tree().get_network_unique_id()
	rpc("add_player", player_id, get_tree().get_network_unique_id())
	
remote func add_player(player_id, peer_id):
	player_id_peers[player_id-1] = peer_id
	emit_signal("player_joined", player_id)
	
func send_set_level(level_id):
	rpc("set_level", level_id)
	
remote func set_level(level_id):
	emit_signal("change_level", level_id)

func send_start_game():
	rpc("start_game")
	
remote func start_game():
	emit_signal("start_game")
