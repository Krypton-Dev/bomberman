extends Control

func _on_exit_pressed():
	get_tree().quit()

func _on_network_pressed():
	OS.alert("Work in progress")


func _on_local_pressed():
	get_tree().change_scene("res://Scripts/UI/LevelSelect.tscn")
