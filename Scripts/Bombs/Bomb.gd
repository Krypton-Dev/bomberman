extends Node2D
export var lifetime = 2
var elapsed = 0
var explosion = preload("res://Scripts/Bombs/Explosion.tscn")
var explosion_range = 3
export var grid_size = 128

var player_id = -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsed += delta
	if elapsed >= lifetime:
		explode()

func explode():
	for x in range(0, explosion_range):
		if not explodeIfSpace(Vector2(-x, 0)):
			break
	
	for x in range(1, explosion_range):
		if not explodeIfSpace(Vector2(x, 0)):
			break
			
	for y in range(0, explosion_range):
		if not explodeIfSpace(Vector2(0, y)):
			break
			
	for y in range(1, explosion_range):
		if not explodeIfSpace(Vector2(0, -y)):
			break
			
	queue_free()	
	
func explodeIfSpace(rel_pos):
	var new_pos = position + rel_pos * grid_size
	var space_state = get_world_2d().direct_space_state.intersect_point(new_pos, 1, [], 1)
	if len(space_state) > 0:
		return false
		
	var explosionInstance = explosion.instance()
	explosionInstance.position = new_pos
	explosionInstance.player_id = player_id
	get_parent().add_child(explosionInstance)
	return true