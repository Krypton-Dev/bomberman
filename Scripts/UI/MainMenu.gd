extends Control

func _on_exit_pressed():
	get_tree().quit()

func _on_network_pressed():
	get_tree().change_scene("res://Scripts/UI/NetworkMenu.tscn")

func _on_local_pressed():
	get_tree().change_scene("res://Scripts/UI/LevelSelect.tscn")
