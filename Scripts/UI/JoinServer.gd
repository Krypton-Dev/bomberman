extends Control

onready var input = $CenterContainer/VBoxContainer/ServerIP
onready var nm = $"/root/NetworkManager"

func _on_back_pressed():
	get_tree().change_scene("res://Scripts/UI/NetworkMenu.tscn")


func _on_join_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(input.text, 54545)
	get_tree().network_peer = peer
	nm.enable_client()
	
	get_tree().change_scene("res://Scripts/UI/LevelSelect.tscn")
