extends Node

var is_network_game = false
var is_server = false
var is_client = false
var connected = false

signal player_joined
signal server_joined
signal server_disconnect
signal change_level

var player_id_peers = [-1,-1,-1,-1]

func _ready():
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
	
func send_add_player(player_id):
	player_id_peers[player_id-1] = get_tree().get_network_unique_id()
	rpc("add_player", player_id)
	
remote func add_player(player_id):
	player_id_peers[player_id-1] = get_tree().get_rpc_sender_id()
	emit_signal("player_joined", player_id)
	
func send_set_level(level_id):
	rpc("set_level", level_id)
	
remote func set_level(level_id):
	emit_signal("change_level", level_id)
