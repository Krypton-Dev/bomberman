extends KinematicBody2D

class_name Player

onready var sprite = $AnimatedSprite
onready var nm = $"/root/NetworkManager"

export var speed = 250
export var player_id = 1
export var spawn_delay = 1.5
export var spawn_safe_time = 3
var spawned = false
var in_safe_mode = true
var spawn_safe_time_elapsed = 0
var spawn_delay_elapsed = 0
var dead = false
var gm = null

puppet var server_position = null

var controller_state = {}

var death_animation = preload("res://Scripts/Player/death_animation.tscn")

func _ready():
	visible = false
	sprite.frames = load("res://Assets/Player/" + GameManager.getColor(player_id) + "/Animation.tres")
	name = "player@" + str(player_id)
	
	gm = get_node("/root/GameManager")
	
func _process(delta):	
	name = "player@" + str(player_id)
	
	spawn_delay_elapsed += delta
	if not spawned and spawn_delay_elapsed >= spawn_delay:
		spawned = true
		visible = true
	
	if not spawned:
		return		
		
	if check_action("fire", true):
		fire()
		
	if not in_safe_mode:
		spawn_safe_time_elapsed += delta
		if spawn_safe_time_elapsed >= spawn_safe_time:
			in_safe_mode = false

func check_action(action, just = false):
	var input_method = gm.get_player(player_id).input_method as String
	if input_method == "network":
		return false # this is a remote player
		
	var device_id = input_method.trim_prefix("controller").trim_prefix("keyboard")
	if input_method.begins_with("keyboard"):
		if just:
			return Input.is_action_just_pressed("player" + device_id + "_" + action)
		else:
			return Input.is_action_pressed("player" + device_id + "_" + action)
			
	if input_method.begins_with("controller"):
		var controller_button = null
		var analog = false
		var analog_axis = null
		var analog_negative = false
		if action == "fire":
			controller_button = JOY_XBOX_A
		elif action == "up":
			controller_button = JOY_DPAD_UP
			analog = true
			analog_negative = true
			analog_axis = JOY_AXIS_1
		elif action == "down":
			controller_button = JOY_DPAD_DOWN
			analog = true
			analog_axis = JOY_AXIS_1
		elif action == "left":
			controller_button = JOY_DPAD_LEFT
			analog = true
			analog_negative = true
			analog_axis = JOY_AXIS_0
		elif action == "right":
			controller_button = JOY_DPAD_RIGHT
			analog = true
			analog_axis = JOY_AXIS_0
		
		if just:
			var ret = false
			if not controller_state.has(action):
				controller_state[action] = false
				
			if Input.is_joy_button_pressed(int(device_id), controller_button):
				if not controller_state[action]:
					ret = true
				controller_state[action] = true
			else:
				controller_state[action] = false
				
			return ret
		else:
			if analog:
				var value = Input.get_joy_axis(int(device_id), analog_axis)
				if analog_negative:
					value = -value
					
				if value >= 0.25:
					return true
			
			return Input.is_joy_button_pressed(int(device_id), controller_button)
		
	# Unimplemented control?!
	return false

func fire():
	if gm.has_item(player_id, "nuke"):
		gm.spawn("nuke", player_id, (position / 128).floor() * 128 + Vector2(64,64))
		gm.remove_item(player_id, "nuke")
		return
	
	if gm.has_item(player_id, "bomb"):
		gm.spawn("bomb", player_id, (position / 128).floor() * 128 + Vector2(64,64))		
		gm.remove_item(player_id, "bomb")
		return


func damage(player_id):
	if dead or not spawned:
		return
		
	dead = true
	if not nm.is_network_game or nm.is_server:
		if player_id != self.player_id:
			gm.grant_score(player_id)
		else:
			gm.grant_score(player_id, -1)
	
	queue_free()
	if not nm.is_network_game or nm.is_server:
		gm.respawn_player(self.player_id)
	
	var animation_instance = death_animation.instance()
	animation_instance.player_id = self.player_id
	animation_instance.position = position
	self.get_parent().add_child(animation_instance)

func _physics_process(delta):
	if not spawned:
		return
		
	if nm.is_network_game:
		if get_network_master() != get_tree().get_network_unique_id():
			if server_position != null:
				position = server_position
				server_position = null
			return
		
	var dir = Vector2()
	if check_action("down"):
		sprite.play("down")
		dir.y += 1	
	if check_action("up"):
		sprite.play("up")
		dir.y -= 1	
	if check_action("left"):
		sprite.play("left")
		dir.x -= 1	
	if check_action("right"):
		sprite.play("right")
		dir.x += 1	
		
	if dir.length() == 0:
		sprite.play("default")
		
	# make sure direction vector is always 1 unit long, so player is not faster when walking directional
	dir = dir.normalized()
		
	move_and_slide(dir * speed)
	if nm.is_network_game:
		rset("server_position", position)
