extends Control

onready var nm = $"/root/NetworkManager"

func _on_back_pressed():
	get_tree().change_scene("res://Scripts/UI/MainMenu.tscn")


func _on_host_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(54545, 4)
	get_tree().set_network_peer(peer)
	nm.enable_server()
	
	get_tree().change_scene("res://Scripts/UI/LevelSelect.tscn")


func _on_join_pressed():
	get_tree().change_scene("res://Scripts/UI/JoinServer.tscn")
