extends Sprite
var time_visible = 1
var time_elapsed = 0
var blink_time = 0.2
var player_id = null
var dead_texture = null
func _ready():
	var texturePath = "res://Assets/Player/" + GameManager.getColor(player_id) + "/dead.png"
	self.texture = load(texturePath)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_elapsed += delta
	if time_elapsed >= time_visible:
		queue_free()
		
	visible = int(time_elapsed / blink_time) % 2 == 0
		