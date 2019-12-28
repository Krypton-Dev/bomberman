extends Area2D

onready var sprite = $AnimatedSprite
var elapsed = 0
export var deadly_timespan = 0.25
var player_id

func _ready():
	sprite.playing = true

func _process(delta):
	elapsed += delta
	
func onAnimationFinish():
	queue_free()


func _body_entered(body):	
	if elapsed <= deadly_timespan:
		body.damage(player_id)
