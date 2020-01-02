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

const free_labels = [
	{input_method = "keyboard1", label = "[center]Press [color=%s]%s[/color] to join[/center]", action = "player1_fire"},
	{input_method = "keyboard2", label = "[center]Press [color=%s]%s[/color] to join[/center]", action = "player2_fire"},
	{input_method = "keyboard3", label = "[center]Press [color=%s]%s[/color] to join[/center]", action = "player3_fire"},
	{input_method = "keyboard4", label = "[center]Press [color=%s]%s[/color] to join[/center]", action = "player4_fire"},
	{input_method = "gamepad", label = "[center]Press [color=%s]any button[/color] to join[/center]", action = null}
]

onready var level_label = $CenterContainer/VBoxContainer/LevelSelector/Label
onready var network_label = $MarginContainer/NetworkLabel
onready var viewport = $CenterContainer/VBoxContainer/ViewportContainer/PreviewViewport
onready var player1 = $CenterContainer/VBoxContainer/Player1
onready var player2 = $CenterContainer/VBoxContainer/Player2
onready var player3 = $CenterContainer/VBoxContainer/Player3
onready var player4 = $CenterContainer/VBoxContainer/Player4
onready var gm = $"/root/GameManager"
onready var nm = $"/root/NetworkManager"

var players = null

var player_count = 0
var current_level_index = 0
var switch_timer = 2
var free_label_index = 0

var used_input_methods = []
var controller_state = {}

func _ready():
	players = [
		{ ui = player1, input_method = null },
		{ ui = player2, input_method = null },
		{ ui = player3, input_method = null },
		{ ui = player4, input_method = null }
	]
	
	show_level(levels[current_level_index])
	update_player_display()
	
	if nm.is_network_game:
		nm.connect("player_joined", self, "_on_player_joined")
		nm.connect("server_joined", self, "_on_joined")
		nm.connect("server_disconnect", self, "_on_leave")
		nm.connect("change_level", self, "_on_change_level")
		
		if nm.is_server:
			network_label.text = "Hosting server"
		else:
			network_label.text = "Joining server"
	else:
		network_label.text = "Local game"
		
func _on_player_joined(player_id):
	add_player("network")
	
func _on_joined():
	network_label.text = "Server joined"
	
func _on_leave():
	get_tree().change_scene("res://Scripts/UI/JoinServer.tscn")
	
func _on_change_level(level_id):
	current_level_index = level_id
	print("change level to ", level_id)
	show_level(levels[current_level_index])
	
func _process(delta):
	if Input.is_action_just_pressed("player1_fire"):
		if not used_input_methods.has("keyboard1"):
			add_player("keyboard1")
	if Input.is_action_just_pressed("player2_fire"):
		if not used_input_methods.has("keyboard2"):
			add_player("keyboard2")
	if Input.is_action_just_pressed("player3_fire"):
		if not used_input_methods.has("keyboard3"):
			add_player("keyboard3")
	if Input.is_action_just_pressed("player4_fire"):
		if not used_input_methods.has("keyboard4"):
			add_player("keyboard4")
			
	for controller in Input.get_connected_joypads():
		if not controller_state.has(controller):
			controller_state[controller] = false
			
		if Input.is_joy_button_pressed(controller, JOY_XBOX_A):
			if not controller_state[controller]:
				if not used_input_methods.has("controller" + str(controller)):
					add_player("controller" + str(controller))
			controller_state[controller] = true
		else:
			controller_state[controller] = false
			
	switch_timer -= delta
	if switch_timer <= 0:
		switch_join_text()
		switch_timer = 2
	
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
	if not nm.is_network_game or nm.is_server:
		if current_level_index + 1 < levels.size():
			current_level_index += 1
			nm.send_set_level(current_level_index)
			show_level(levels[current_level_index])

func _on_prev_pressed():
	if not nm.is_network_game or nm.is_server:
		if current_level_index - 1 >= 0:
			current_level_index -= 1
			nm.send_set_level(current_level_index)
			show_level(levels[current_level_index])

func _on_start_pressed():
	var gm = get_node("/root/GameManager")
	get_tree().change_scene(levels[current_level_index]["path"])

func _on_back_pressed():
	get_tree().change_scene("res://Scripts/UI/MainMenu.tscn")
	
func add_player(input):
	if player_count >= 4:
		return
	
	if input != "network":
		nm.send_add_player(player_count + 1)
		used_input_methods.push_back(input)
		
	players[player_count].input_method = input
	player_count = player_count + 1
	
	gm.add_player(input)
	
	update_player_display()
	
func update_player_display():
	for i in range(player_count):
		var label = players[i].ui.get_node("Label")
		label.bbcode_text = "[center][color=" + get_player_color(i) + "]Player " + str(i+1) + "[/color]  [img=26x26]" + get_input_icon(players[i].input_method) + "[/img][/center]"
		players[i].ui.show()
		
	if player_count == 4:
		return # we have no more player spaces available
		
	players[player_count].ui.show()
	var free_label = players[player_count].ui.get_node("Label")
	var action = free_labels[free_label_index].action
	var formats = [get_player_color(player_count)]
	if action != null:
		var action_list = InputMap.get_action_list(action)
		if action_list != null and not action_list.empty():
			formats.push_back(action_list.front().as_text())
	
	free_label.bbcode_text = free_labels[free_label_index].label % (formats)
		
	for i in range(player_count + 1, 4):
		players[i].ui.hide()
		
func switch_join_text():
	free_label_index += 1
	if free_label_index >= free_labels.size():
		free_label_index = 0
		
	if used_input_methods.has(free_labels[free_label_index].input_method):
		switch_join_text() # input method is used switch again
		
	update_player_display()
	
func get_player_color(player_id):
	if player_id == 0:
		return "#28b162"
	if player_id == 1:
		return "#a03939"
	if player_id == 2:
		return "#398ea0"
	if player_id == 3:
		return "#8739a0"
		
func get_input_icon(input_method: String):
	if input_method.begins_with("keyboard"):
		return "Assets/UI/" + input_method + ".png"
	if input_method.begins_with("controller"):
		var input_device_id = int(input_method.trim_prefix("controller"))
		return "Assets/UI/controller" + str(input_device_id+1) + ".png"
	if input_method.begins_with("network"):
		return "Assets/UI/keyboard1.png" #todo

func _on_connected():
	network_label.text = "Server joined"
