extends KinematicBody2D

# Declare member variables here. Examples:
class_name Player

onready var sprite = $AnimatedSprite

# var a = 2
# var b = "text"
export var speed = 250
export var playerId = 1
var bomb = preload("res://Scripts/Bombs/Bomb.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.frames = load("res://Assets/Player/" + getColor() + "/Animation.tres")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	if Input.is_action_just_pressed(getInputAction("fire")):
		print("fire")
		fire()


func fire():
	var newBomb = bomb.instance()
	newBomb.player_id = playerId
	newBomb.position = (position / 128).floor() * 128 + Vector2(64,64)
	get_parent().add_child(newBomb)
	
func damage(player_id):
	print("Damage by ", player_id)

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
	
func getColor():
	if playerId == 1:
		return "Green"
	if playerId == 2:
		return "Red"
	if playerId == 3:
		return "Blue"
	if playerId == 4:
		return "Purple"
		
	return "Green"