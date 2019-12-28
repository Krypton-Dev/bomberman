extends Area2D

onready var sprite = $AnimatedSprite

var player_id
func _ready():
	sprite.playing = true

func onAnimationFinish():
	queue_free()


func _body_entered(body):	
	body.damage(player_id)
