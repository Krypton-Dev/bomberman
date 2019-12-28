extends Control

const levels = [
	{ 
		name = "Dev Level",
		path = "res://Levels/Dev.tscn"
	},
	{ 
		name = "Desert",
		path = "res://Levels/Desert.tscn"
	},
]

onready var level_label = $VBoxContainer/HBoxContainer/Label
onready var viewport = $VBoxContainer/ViewportContainer/PreviewViewport
onready var preview = $TextureRect

var current_level_index = 0

func _ready():
	show_level(levels[current_level_index])
	
	
func show_level(level):
	level_label.text = level["name"]
	generate_preview(level["path"])

func generate_preview(scenePath: String):
	for child in viewport.get_children():
		child.queue_free()
	
	var scene: Node = load(scenePath).instance()
	scene.preview = true
	scene.get_node("UI").queue_free()
	
	scene.set_process(false)
	scene.set_process_input(false)
	scene.set_physics_process(false)
	viewport.add_child(scene)

func _on_next_pressed():
	if current_level_index + 1 < levels.size():
		current_level_index += 1
		show_level(levels[current_level_index])


func _on_prev_pressed():
	if current_level_index - 1 >= 0:
		current_level_index -= 1
		show_level(levels[current_level_index])

func _on_start_pressed():
	var gm = get_node("/root/GameManager")
	get_tree().change_scene(levels[current_level_index]["path"])
