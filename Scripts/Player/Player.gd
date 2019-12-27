extends KinematicBody2D

# Declare member variables here. Examples:
class_name Player

onready var sprite = $AnimatedSprite

# var a = 2
# var b = "text"
export var speed = 250
export var playerId = 1
export var spawn_delay = 1.5
export var spawn_safe_time = 3
var spawned = false
var in_safe_mode = true
var spawn_safe_time_elapsed = 0
var spawn_delay_elapsed = 0

var bomb = preload("res://Scripts/Bombs/Bomb.tscn")
var death_animation = preload("res://Assets/Player/death_animation.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	sprite.frames = load("res://Assets/Player/" + GameManager.getColor(playerId) + "/Animation.tres")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	spawn_delay_elapsed += delta
	if not spawned and spawn_delay_elapsed >= spawn_delay:
		spawned = true
		visible = true
	
	if not spawned:
		return		

	if Input.is_action_just_pressed(getInputAction("fire")):
		print("fire")
		fire()
		
	if not in_safe_mode:
		spawn_safe_time_elapsed += delta
		if spawn_safe_time_elapsed >= spawn_safe_time:
			in_safe_mode = false


func fire():
	var newBomb = bomb.instance()
	newBomb.player_id = playerId
	newBomb.position = (position / 128).floor() * 128 + Vector2(64,64)
	get_parent().add_child(newBomb)
	
func damage(player_id):
	print("Damage by ", player_id)
	
	queue_free()
	GameManager.respawn_player(player_id)
	
	var animation_instance = death_animation.instance()
	animation_instance.position = position
	self.get_parent().add_child(animation_instance)
	
	

func _physics_process(delta):
	var dir = Vector2()
	if Input.is_action_pressed(getInputAction("down")):
		sprite.play("down")
		dir.y += 1	
	if Input.is_action_pressed(getInputAction("up")):
		sprite.play("up")
		dir.y -= 1	
	if Input.is_action_pressed(getInputAction("left")):
		sprite.play("left")
		dir.x -= 1	
	if Input.is_action_pressed(getInputAction("right")):
		sprite.play("right")
		dir.x += 1	
		
	if dir.length() == 0:
		sprite.play("default")
		
	move_and_slide(dir * speed)
	
	
func getInputAction(action):
	return "player" + str(playerId) + "_" + action
	